class PagesController < ApplicationController
  def about
    @providers = Provider.order(:name)
    @last_imports = PricingImport.where(status: "completed")
      .order(completed_at: :desc)
      .includes(:provider)
      .group_by(&:provider_id)
      .transform_values(&:first)
  end
end
