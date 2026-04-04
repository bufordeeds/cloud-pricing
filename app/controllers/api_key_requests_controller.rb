class ApiKeyRequestsController < ApplicationController
  def new
    @api_key = ApiKey.new
  end

  def create
    @api_key = ApiKey.new(api_key_params)
    @api_key.status = "pending"

    if @api_key.save
      ApiKeyMailer.new_request(@api_key).deliver_now
      redirect_to thanks_api_key_requests_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def thanks
  end

  private

  def api_key_params
    params.require(:api_key).permit(:name, :email)
  end
end
