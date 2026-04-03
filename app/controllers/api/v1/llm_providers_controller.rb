module Api
  module V1
    class LlmProvidersController < BaseController
      def index
        providers = LlmProvider.order(:name)

        render json: {
          data: providers.map { |p|
            {
              id: p.id,
              name: p.name,
              slug: p.slug,
              model_count: p.llm_models.count
            }
          }
        }
      end
    end
  end
end
