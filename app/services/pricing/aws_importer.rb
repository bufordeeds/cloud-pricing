module Pricing
  class AwsImporter < BaseImporter
    URL = "https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AmazonEC2/current/us-east-1/index.json"

    private

    def provider_slug = "aws"

    def perform_import
      Rails.logger.info "[AWS] Fetching pricing data (this may take a while)..."

      records = []
      products = {}
      terms = {}

      # Stream the large JSON file in chunks
      uri = URI(URL)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 300, open_timeout: 60) do |http|
        http.request(Net::HTTP::Get.new(uri))
      end

      Rails.logger.info "[AWS] Parsing JSON response (#{response.body.bytesize / 1_000_000}MB)..."
      data = Oj.load(response.body, mode: :compat)

      # Build products hash
      data["products"]&.each do |sku, product|
        attrs = product["attributes"] || {}
        next unless attrs["operatingSystem"] == "Linux"
        next unless attrs["tenancy"] == "Shared"
        next unless attrs["capacitystatus"] == "Used"
        next unless attrs["preInstalledSw"] == "NA"
        next if attrs["instanceType"].nil? || attrs["instanceType"].empty?

        products[sku] = {
          instance_type: attrs["instanceType"],
          vcpus: attrs["vcpu"]&.to_i,
          memory_gb: parse_memory(attrs["memory"]),
          family: categorize_family(attrs["instanceFamily"]),
          region: "us-east-1",
          operating_system: "Linux"
        }
      end

      # Extract on-demand pricing
      data.dig("terms", "OnDemand")&.each do |_sku, term_variants|
        term_variants.each do |_offer_term_code, term|
          sku = term["sku"]
          next unless products[sku]

          term["priceDimensions"]&.each do |_rate_code, dimension|
            next unless dimension.dig("unit") == "Hrs"
            price = dimension.dig("pricePerUnit", "USD")&.to_f
            next if price.nil? || price <= 0

            product = products[sku]
            next if product[:vcpus].nil? || product[:vcpus] <= 0
            next if product[:memory_gb].nil? || product[:memory_gb] <= 0

            records << {
              instance_type: product[:instance_type],
              vcpus: product[:vcpus],
              memory_gb: product[:memory_gb],
              family: product[:family],
              price_per_hour: price,
              region: product[:region],
              operating_system: product[:operating_system],
              raw_attributes: {}
            }
          end
        end
      end

      # Deduplicate by instance_type (keep lowest price)
      records = records
        .group_by { |r| r[:instance_type] }
        .map { |_type, group| group.min_by { |r| r[:price_per_hour] } }

      upsert_instances_bulk(records)
    end

    def parse_memory(memory_str)
      return nil if memory_str.nil?
      memory_str.gsub(",", "").to_f
    end

    def categorize_family(family)
      case family
      when /General/i then "General Purpose"
      when /Compute/i then "Compute Optimized"
      when /Memory/i then "Memory Optimized"
      when /Storage/i then "Storage Optimized"
      when /Accelerated/i, /GPU/i then "Accelerated Computing"
      else family
      end
    end
  end
end
