module Api
  module V1
    class InstancesController < BaseController
      def index
        instances = Instance.includes(:provider)
          .by_provider(params[:providers])
          .by_vcpus(params[:vcpus_min], params[:vcpus_max])
          .by_memory(params[:memory_min], params[:memory_max])
          .by_family(params[:family])
          .search(params[:q])
          .sorted_by(params[:sort] || "price", params[:direction] || "asc")

        pagy, records = paginate(instances)

        render json: {
          data: records.map { |i| instance_json(i) },
          meta: pagination_meta(pagy)
        }
      end

      def show
        instance = Instance.includes(:provider).find(params[:id])
        render json: { data: instance_json(instance) }
      end

      private

      def instance_json(instance)
        {
          id: instance.id,
          instance_type: instance.instance_type,
          family: instance.family,
          vcpus: instance.vcpus,
          memory_gb: instance.memory_gb,
          price_per_hour: instance.price_per_hour.to_f,
          monthly_cost: instance.monthly_cost.to_f,
          price_per_vcpu: instance.price_per_vcpu.to_f,
          price_per_gb_memory: instance.price_per_gb_memory.to_f,
          region: instance.region,
          operating_system: instance.operating_system,
          provider: {
            name: instance.provider.name,
            slug: instance.provider.slug
          }
        }
      end
    end
  end
end
