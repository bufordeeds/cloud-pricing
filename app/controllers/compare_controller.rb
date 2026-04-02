class CompareController < ApplicationController
  def show
    ids = params[:ids].to_s.split(",").map(&:to_i).first(4)
    @instances = Instance.includes(:provider).where(id: ids)

    redirect_to instances_path, alert: "Select at least 2 instances to compare." if @instances.size < 2
  end
end
