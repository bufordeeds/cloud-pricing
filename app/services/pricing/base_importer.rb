module Pricing
  class BaseImporter
    attr_reader :provider, :pricing_import

    def initialize
      @provider = Provider.find_by!(slug: provider_slug)
      @pricing_import = @provider.pricing_imports.create!(status: "pending")
    end

    def import!
      pricing_import.mark_running!
      count = perform_import
      pricing_import.mark_completed!(count)
      Rails.logger.info "[#{provider.name}] Imported #{count} instances"
      count
    rescue => e
      pricing_import.mark_failed!(e.message)
      Rails.logger.error "[#{provider.name}] Import failed: #{e.message}"
      raise
    end

    private

    def provider_slug
      raise NotImplementedError
    end

    def perform_import
      raise NotImplementedError
    end

    def upsert_instance(attrs)
      instance = provider.instances.find_or_initialize_by(
        instance_type: attrs[:instance_type],
        region: attrs[:region]
      )
      instance.assign_attributes(attrs)
      instance.save!
      instance
    end

    def upsert_instances_bulk(records)
      return 0 if records.empty?

      now = Time.current
      records.each do |r|
        r[:provider_id] = provider.id
        r[:created_at] = now
        r[:updated_at] = now
      end

      Instance.upsert_all(
        records,
        unique_by: [ :provider_id, :instance_type, :region ]
      )

      records.size
    end
  end
end
