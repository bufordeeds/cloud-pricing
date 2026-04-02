module Pricing
  class AzureImporter < BaseImporter
    BASE_URL = "https://prices.azure.com/api/retail/prices"

    private

    def provider_slug = "azure"

    def perform_import
      Rails.logger.info "[Azure] Fetching pricing data..."

      records = []
      url = build_url
      page = 0

      loop do
        page += 1
        Rails.logger.info "[Azure] Fetching page #{page}..."

        response = HTTParty.get(url, timeout: 60)
        data = response.parsed_response

        items = data["Items"] || []
        break if items.empty?

        items.each do |item|
          next unless valid_item?(item)

          records << {
            instance_type: item["armSkuName"],
            vcpus: extract_vcpus(item),
            memory_gb: extract_memory(item),
            family: categorize_family(item["armSkuName"]),
            price_per_hour: item["retailPrice"].to_f,
            region: "eastus",
            operating_system: "Linux",
            raw_attributes: {
              meter_name: item["meterName"],
              product_name: item["productName"],
              sku_name: item["skuName"]
            }
          }
        end

        url = data["NextPageLink"]
        break if url.nil?
      end

      # Deduplicate by instance_type, keep lowest price
      records = records
        .select { |r| r[:vcpus] > 0 && r[:memory_gb] > 0 && r[:price_per_hour] > 0 }
        .group_by { |r| r[:instance_type] }
        .map { |_type, group| group.min_by { |r| r[:price_per_hour] } }

      upsert_instances_bulk(records)
    end

    def build_url
      filter = [
        "serviceName eq 'Virtual Machines'",
        "priceType eq 'Consumption'",
        "armRegionName eq 'eastus'"
      ].join(" and ")

      "#{BASE_URL}?$filter=#{CGI.escape(filter)}"
    end

    def valid_item?(item)
      return false if item["retailPrice"].nil? || item["retailPrice"] <= 0
      return false if item["armSkuName"].nil? || item["armSkuName"].empty?
      return false unless item["unitOfMeasure"] == "1 Hour"
      return false if item["skuName"]&.include?("Windows")
      return false if item["productName"]&.include?("Windows")
      return false if item["skuName"]&.include?("Spot")
      return false if item["skuName"]&.include?("Low Priority")
      true
    end

    def extract_vcpus(item)
      sku = item["armSkuName"] || ""
      # Try to extract from common patterns like Standard_D4s_v3
      match = sku.match(/(\d+)/)
      match ? match[1].to_i : 0
    end

    def extract_memory(item)
      # Azure API doesn't consistently include memory in pricing API
      # Use known mappings for common VM sizes
      sku = item["armSkuName"] || ""
      AZURE_VM_MEMORY[sku] || estimate_memory(sku)
    end

    def estimate_memory(sku)
      # Estimate based on vCPU count and VM family
      vcpus = extract_vcpus({ "armSkuName" => sku })
      return 0 if vcpus == 0

      case sku
      when /Standard_E|Standard_M/i  # Memory optimized
        vcpus * 8.0
      when /Standard_F|Standard_Fs/i  # Compute optimized
        vcpus * 2.0
      when /Standard_L/i  # Storage optimized
        vcpus * 8.0
      when /Standard_N|Standard_NC|Standard_ND/i  # GPU
        vcpus * 6.0
      else  # General purpose (D-series, B-series, etc.)
        vcpus * 4.0
      end
    end

    def categorize_family(sku)
      case sku
      when /Standard_F|Standard_Fs/i then "Compute Optimized"
      when /Standard_E|Standard_M/i then "Memory Optimized"
      when /Standard_L/i then "Storage Optimized"
      when /Standard_N|Standard_NC|Standard_ND/i then "Accelerated Computing"
      else "General Purpose"
      end
    end

    # Known Azure VM memory mappings (GB) for common sizes
    AZURE_VM_MEMORY = {
      "Standard_B1ls" => 0.5, "Standard_B1s" => 1, "Standard_B1ms" => 2,
      "Standard_B2s" => 4, "Standard_B2ms" => 8, "Standard_B4ms" => 16,
      "Standard_B8ms" => 32, "Standard_B12ms" => 48, "Standard_B16ms" => 64,
      "Standard_B20ms" => 80,
      "Standard_D2s_v3" => 8, "Standard_D4s_v3" => 16, "Standard_D8s_v3" => 32,
      "Standard_D16s_v3" => 64, "Standard_D32s_v3" => 128, "Standard_D48s_v3" => 192,
      "Standard_D64s_v3" => 256,
      "Standard_D2s_v5" => 8, "Standard_D4s_v5" => 16, "Standard_D8s_v5" => 32,
      "Standard_D16s_v5" => 64, "Standard_D32s_v5" => 128, "Standard_D48s_v5" => 192,
      "Standard_D64s_v5" => 256, "Standard_D96s_v5" => 384,
      "Standard_E2s_v3" => 16, "Standard_E4s_v3" => 32, "Standard_E8s_v3" => 64,
      "Standard_E16s_v3" => 128, "Standard_E32s_v3" => 256, "Standard_E48s_v3" => 384,
      "Standard_E64s_v3" => 432,
      "Standard_F2s_v2" => 4, "Standard_F4s_v2" => 8, "Standard_F8s_v2" => 16,
      "Standard_F16s_v2" => 32, "Standard_F32s_v2" => 64, "Standard_F48s_v2" => 96,
      "Standard_F64s_v2" => 128, "Standard_F72s_v2" => 144
    }.freeze
  end
end
