class LlmModelsController < ApplicationController
  include Pagy::Backend

  def index
    models = LlmModel.includes(:llm_provider)
      .by_provider(params[:providers])
      .by_context_window(params[:context_min], params[:context_max])
      .search(params[:q])
      .sorted_by(params[:sort] || "input_price", params[:direction] || "asc")

    @pagy, @llm_models = pagy(models, limit: 25)
    @providers = LlmProvider.order(:name)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @llm_model = LlmModel.includes(:llm_provider).find(params[:id])
    @similar = LlmModel.includes(:llm_provider)
      .where.not(id: @llm_model.id)
      .where(
        input_price_per_mtok: (@llm_model.input_price_per_mtok * 0.3)..(@llm_model.input_price_per_mtok * 3)
      )
      .order(:input_price_per_mtok)
      .limit(5)
  end
end
