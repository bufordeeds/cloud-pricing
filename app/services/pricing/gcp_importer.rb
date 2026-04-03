module Pricing
  class GcpImporter < BaseImporter
    SERVICE_ID = "6F81-5844-456A" # Compute Engine
    SKUS_URL = "https://cloudbilling.googleapis.com/v1/services/#{SERVICE_ID}/skus".freeze
    TARGET_REGION = "us-central1".freeze

    # Map SKU description prefixes to machine family slugs
    FAMILY_SKU_MAP = {
      /\AE2 Instance (Core|Ram)/ => "e2",
      /\AN2D AMD Instance (Core|Ram)/ => "n2d",
      /\AN2 Instance (Core|Ram)/ => "n2",
      /\ACustom Instance (Core|Ram)/ => "n1",
      /\ACompute optimized (Core|Ram)/ => "c2",
      /\AC3 Instance (Core|Ram)/ => "c3",
      /\AMemory-optimized Instance (Core|Ram)/ => "m1"
    }.freeze

    # Machine type specs: { vcpus => memory_gb }
    MACHINE_TYPE_SPECS = {
      "n1-standard" => { 1 => 3.75, 2 => 7.5, 4 => 15, 8 => 30, 16 => 60, 32 => 120, 64 => 240, 96 => 360 },
      "n2-standard" => { 2 => 8, 4 => 16, 8 => 32, 16 => 64, 32 => 128, 48 => 192, 64 => 256, 80 => 320, 96 => 384, 128 => 512 },
      "n2d-standard" => { 2 => 8, 4 => 16, 8 => 32, 16 => 64, 32 => 128, 48 => 192, 64 => 256, 80 => 320, 96 => 384, 128 => 512, 224 => 896 },
      "e2-standard" => { 2 => 8, 4 => 16, 8 => 32, 16 => 64, 32 => 128 },
      "c2-standard" => { 4 => 16, 8 => 32, 16 => 64, 30 => 120, 60 => 240 },
      "c3-standard" => { 4 => 16, 8 => 32, 22 => 88, 44 => 176, 88 => 352, 176 => 704 },
      "m1-megamem" => { 96 => 1433.6 },
      "m1-ultramem" => { 40 => 961, 80 => 1922, 160 => 3844 },
      "n1-highmem" => { 2 => 13, 4 => 26, 8 => 52, 16 => 104, 32 => 208, 64 => 416, 96 => 624 },
      "n2-highmem" => { 2 => 16, 4 => 32, 8 => 64, 16 => 128, 32 => 256, 48 => 384, 64 => 512, 80 => 640, 96 => 768, 128 => 864 },
      "e2-highmem" => { 2 => 16, 4 => 32, 8 => 64, 16 => 128 },
      "n1-highcpu" => { 2 => 1.8, 4 => 3.6, 8 => 7.2, 16 => 14.4, 32 => 28.8, 64 => 57.6, 96 => 86.4 },
      "n2-highcpu" => { 2 => 2, 4 => 4, 8 => 8, 16 => 16, 32 => 32, 48 => 48, 64 => 64, 80 => 80, 96 => 96 },
      "e2-highcpu" => { 2 => 2, 4 => 4, 8 => 8, 16 => 16, 32 => 32 }
    }.freeze

    # Shared-core instances with fixed hourly pricing (us-central1, Linux, on-demand)
    SMALL_INSTANCES = {
      "f1-micro" => { vcpus: 1, memory_gb: 0.6, price_per_hour: 0.0076 },
      "g1-small" => { vcpus: 1, memory_gb: 1.7, price_per_hour: 0.0257 },
      "e2-micro" => { vcpus: 2, memory_gb: 1.0, price_per_hour: 0.0084 },
      "e2-small" => { vcpus: 2, memory_gb: 2.0, price_per_hour: 0.0168 },
      "e2-medium" => { vcpus: 2, memory_gb: 4.0, price_per_hour: 0.0336 }
    }.freeze

    private

    def provider_slug = "gcp"

    def perform_import
      api_key = ENV.fetch("GCP_API_KEY") do
        raise "GCP_API_KEY environment variable is required for GCP pricing import"
      end

      Rails.logger.info "[GCP] Fetching pricing rates from Cloud Billing API..."
      family_rates = fetch_family_rates(api_key)
      Rails.logger.info "[GCP] Found rates for families: #{family_rates.keys.sort.join(', ')}"

      records = []

      # Build records for standard machine types using per-component rates
      MACHINE_TYPE_SPECS.each do |family_prefix, sizes|
        slug = family_prefix.split("-").first(2).first # e.g. "n2-standard" → "n2"
        # For families like "m1-megamem", the slug is "m1"
        slug = family_prefix.match(/\A([a-z]\d+)/)[1]
        rates = family_rates[slug]
        unless rates
          Rails.logger.warn "[GCP] No billing rates found for family '#{slug}', skipping #{family_prefix}"
          next
        end

        sizes.each do |vcpus, memory_gb|
          instance_type = "#{family_prefix}-#{vcpus}"
          price = (vcpus * rates[:cpu]) + (memory_gb * rates[:ram])

          records << build_record(instance_type, vcpus, memory_gb, price, family_prefix)
        end
      end

      # Add shared-core / small instances with known fixed pricing
      SMALL_INSTANCES.each do |instance_type, specs|
        records << build_record(
          instance_type, specs[:vcpus], specs[:memory_gb],
          specs[:price_per_hour], instance_type
        )
      end

      upsert_instances_bulk(records)
    end

    def fetch_family_rates(api_key)
      rates = {} # { "e2" => { cpu: Float, ram: Float }, ... }
      page_token = nil

      loop do
        url = "#{SKUS_URL}?key=#{api_key}&pageSize=5000"
        url += "&pageToken=#{page_token}" if page_token

        response = HTTParty.get(url, timeout: 60)
        data = response.parsed_response
        skus = data["skus"] || []

        skus.each do |sku|
          cat = sku["category"] || {}
          next unless cat["resourceFamily"] == "Compute"
          next unless cat["usageType"] == "OnDemand"

          group = cat["resourceGroup"]
          next unless %w[CPU RAM].include?(group)

          regions = sku["serviceRegions"] || []
          next unless regions.include?(TARGET_REGION)

          desc = sku["description"] || ""
          family_slug = match_family(desc)
          next unless family_slug

          price = extract_price(sku)
          next if price.nil? || price <= 0

          rates[family_slug] ||= {}
          key = group == "CPU" ? :cpu : :ram
          rates[family_slug][key] = price
        end

        page_token = data["nextPageToken"]
        break if page_token.nil? || page_token.empty?
      end

      rates
    end

    def match_family(description)
      FAMILY_SKU_MAP.each do |pattern, slug|
        return slug if description.match?(pattern)
      end
      nil
    end

    def extract_price(sku)
      pricing = sku.dig("pricingInfo", 0, "pricingExpression", "tieredRates", 0, "unitPrice")
      return nil unless pricing

      units = pricing["units"].to_i
      nanos = pricing["nanos"].to_i
      units + (nanos / 1_000_000_000.0)
    end

    def build_record(instance_type, vcpus, memory_gb, price, family_prefix)
      {
        instance_type: instance_type,
        vcpus: vcpus,
        memory_gb: memory_gb,
        family: categorize_family(family_prefix),
        price_per_hour: price.round(6),
        region: TARGET_REGION,
        operating_system: "Linux",
        raw_attributes: {}
      }
    end

    def categorize_family(machine_type)
      case machine_type
      when /highcpu|c2|c3/ then "Compute Optimized"
      when /highmem|megamem|ultramem|m1|m2|m3/ then "Memory Optimized"
      when /a2|g2/ then "Accelerated Computing"
      else "General Purpose"
      end
    end
  end
end
