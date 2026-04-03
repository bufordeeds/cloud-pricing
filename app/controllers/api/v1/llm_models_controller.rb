module Api
  module V1
    class LlmModelsController < BaseController
      def index
        models = LlmModel.includes(:llm_provider)
          .by_provider(params[:providers])
          .by_context_window(params[:context_min], params[:context_max])
          .search(params[:q])
          .sorted_by(params[:sort] || "input_price", params[:direction] || "asc")

        pagy, records = paginate(models)

        render json: {
          data: records.map { |m| llm_model_json(m) },
          meta: pagination_meta(pagy)
        }
      end

      def show
        model = LlmModel.includes(:llm_provider).find(params[:id])
        render json: { data: llm_model_json(model) }
      end

      private

      def llm_model_json(model)
        {
          id: model.id,
          name: model.name,
          model_id: model.model_id,
          context_window: model.context_window,
          input_price_per_mtok: model.input_price_per_mtok.to_f,
          output_price_per_mtok: model.output_price_per_mtok.to_f,
          blended_price_per_mtok: model.blended_price_per_mtok.to_f,
          supports_vision: model.supports_vision,
          supports_tool_use: model.supports_tool_use,
          supports_extended_thinking: model.supports_extended_thinking,
          capabilities: model.capabilities,
          provider: {
            name: model.llm_provider.name,
            slug: model.llm_provider.slug
          }
        }
      end
    end
  end
end
