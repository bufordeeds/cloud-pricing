class ChartsController < ApplicationController
  def index
    @instances = Instance.includes(:provider).all
    @providers = Provider.order(:name)
  end
end
