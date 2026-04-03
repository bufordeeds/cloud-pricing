module Admin
  class ApiKeysController < BaseController
    def index
      @pending = ApiKey.pending.order(created_at: :desc)
      @active = ApiKey.active.order(created_at: :desc)
      @inactive = ApiKey.inactive.order(created_at: :desc)
    end

    def approve
      api_key = ApiKey.find(params[:id])
      token = api_key.generate_token!
      ApiKeyMailer.approved(api_key, token).deliver_now

      redirect_to admin_api_keys_path, notice: "API key approved and emailed to #{api_key.email}"
    end

    def deny
      api_key = ApiKey.find(params[:id])
      api_key.deny!(params[:notes])

      redirect_to admin_api_keys_path, notice: "Request from #{api_key.email} denied"
    end

    def revoke
      api_key = ApiKey.find(params[:id])
      api_key.revoke!

      redirect_to admin_api_keys_path, notice: "API key for #{api_key.email} revoked"
    end
  end
end
