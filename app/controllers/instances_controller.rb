class InstancesController < ApplicationController
  include Pagy::Backend

  def index
    instances = Instance.includes(:provider)
      .by_provider(params[:providers])
      .by_vcpus(params[:vcpus_min], params[:vcpus_max])
      .by_memory(params[:memory_min], params[:memory_max])
      .by_family(params[:family])
      .search(params[:q])
      .sorted_by(params[:sort] || "price", params[:direction] || "asc")

    @pagy, @instances = pagy(instances, limit: 25)
    @providers = Provider.order(:name)
    @families = Instance.distinct.pluck(:family).compact.sort

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @instance = Instance.includes(:provider).find(params[:id])
    @similar = Instance.includes(:provider)
      .where.not(id: @instance.id)
      .where(vcpus: (@instance.vcpus - 2)..(@instance.vcpus + 2))
      .order(:price_per_hour)
      .limit(5)
  end
end
