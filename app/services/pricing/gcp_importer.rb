module Pricing
  class GcpImporter < BaseImporter
    URL = "https://cloudpricingcalculator.appspot.com/static/data/pricelist.json"

    MACHINE_TYPE_SPECS = {
      # Standard machine types: { vcpus => memory_gb }
      "n1-standard" => { 1 => 3.75, 2 => 7.5, 4 => 15, 8 => 30, 16 => 60, 32 => 120, 64 => 240, 96 => 360 },
      "n2-standard" => { 2 => 8, 4 => 16, 8 => 32, 16 => 64, 32 => 128, 48 => 192, 64 => 256, 80 => 320, 96 => 384, 128 => 512 },
      "n2d-standard" => { 2 => 8, 4 => 16, 8 => 32, 16 => 64, 32 => 128, 48 => 192, 64 => 256, 80 => 320, 96 => 384, 128 => 512, 224 => 896 },
      "e2-standard" => { 2 => 8, 4 => 16, 8 => 32, 16 => 64, 32 => 128 },
      "c2-standard" => { 4 => 16, 8 => 32, 16 => 64, 30 => 120, 60 => 240 },
      "c3-standard" => { 4 => 16, 8 => 32, 22 => 88, 44 => 176, 88 => 352, 176 => 704 },
      "m1-megamem" => { 96 => 1433.6 },
      "m1-ultramem" => { 40 => 961, 80 => 1922, 160 => 3844 },
      # High-mem
      "n1-highmem" => { 2 => 13, 4 => 26, 8 => 52, 16 => 104, 32 => 208, 64 => 416, 96 => 624 },
      "n2-highmem" => { 2 => 16, 4 => 32, 8 => 64, 16 => 128, 32 => 256, 48 => 384, 64 => 512, 80 => 640, 96 => 768, 128 => 864 },
      "e2-highmem" => { 2 => 16, 4 => 32, 8 => 64, 16 => 128 },
      # High-cpu
      "n1-highcpu" => { 2 => 1.8, 4 => 3.6, 8 => 7.2, 16 => 14.4, 32 => 28.8, 64 => 57.6, 96 => 86.4 },
      "n2-highcpu" => { 2 => 2, 4 => 4, 8 => 8, 16 => 16, 32 => 32, 48 => 48, 64 => 64, 80 => 80, 96 => 96 },
      "e2-highcpu" => { 2 => 2, 4 => 4, 8 => 8, 16 => 16, 32 => 32 },
      # Small/micro/medium
      "e2-micro" => { 0 => 0 },
      "e2-small" => { 0 => 0 },
      "e2-medium" => { 0 => 0 },
      "f1-micro" => { 0 => 0 },
      "g1-small" => { 0 => 0 }
    }

    # Small instance specs
    SMALL_INSTANCES = {
      "f1-micro" => { vcpus: 1, memory_gb: 0.6 },
      "g1-small" => { vcpus: 1, memory_gb: 1.7 },
      "e2-micro" => { vcpus: 2, memory_gb: 1 },
      "e2-small" => { vcpus: 2, memory_gb: 2 },
      "e2-medium" => { vcpus: 2, memory_gb: 4 }
    }

    private

    def provider_slug = "gcp"

    def perform_import
      Rails.logger.info "[GCP] Fetching pricing data..."
      response = HTTParty.get(URL, timeout: 120)
      data = response.parsed_response

      pricelist = data["gcp_price_list"] || {}
      records = []

      pricelist.each do |key, value|
        next unless key.start_with?("CP-COMPUTEENGINE-VMIMAGE-")
        next unless value.is_a?(Hash)

        price = value["us"]&.to_f
        next if price.nil? || price <= 0

        machine_type = key.sub("CP-COMPUTEENGINE-VMIMAGE-", "").downcase
        specs = resolve_specs(machine_type)
        next if specs.nil?

        records << {
          instance_type: machine_type,
          vcpus: specs[:vcpus],
          memory_gb: specs[:memory_gb],
          family: categorize_family(machine_type),
          price_per_hour: price,
          region: "us-central1",
          operating_system: "Linux",
          raw_attributes: {}
        }
      end

      upsert_instances_bulk(records)
    end

    def resolve_specs(machine_type)
      # Check small/special instances first
      return SMALL_INSTANCES[machine_type] if SMALL_INSTANCES.key?(machine_type)

      # Parse family-size pattern like "n2-standard-4"
      parts = machine_type.match(/^(.+)-(\d+)$/)
      return nil unless parts

      family_prefix = parts[1]
      vcpus = parts[2].to_i
      specs = MACHINE_TYPE_SPECS[family_prefix]
      return nil unless specs

      memory = specs[vcpus]
      return nil unless memory

      { vcpus: vcpus, memory_gb: memory }
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
