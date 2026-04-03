module Api
  module V1
    class ProvidersController < BaseController
      def index
        providers = Provider.order(:name)

        render json: {
          data: providers.map { |p|
            {
              id: p.id,
              name: p.name,
              slug: p.slug,
              instance_count: p.instances.count
            }
          }
        }
      end
    end
  end
end
