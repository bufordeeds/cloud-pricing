module Api
  module V1
    class BaseController < ActionController::API
      include Pagy::Backend

      before_action :authenticate!
      before_action :rate_limit!
      after_action :track_usage

      private

      def authenticate!
        token = request.headers["Authorization"]&.delete_prefix("Bearer ")
        @current_api_key = ApiKey.authenticate(token)

        unless @current_api_key
          render json: { error: "Invalid or missing API key" }, status: :unauthorized
        end
      end

      def rate_limit!
        return unless @current_api_key

        key = "rate_limit:#{@current_api_key.id}"
        count = Rails.cache.increment(key, 1, expires_in: 1.minute, initial: 0)

        limit = 100
        remaining = [ limit - count, 0 ].max

        response.set_header("X-RateLimit-Limit", limit.to_s)
        response.set_header("X-RateLimit-Remaining", remaining.to_s)

        if count > limit
          response.set_header("Retry-After", "60")
          render json: { error: "Rate limit exceeded. Try again in 60 seconds." }, status: :too_many_requests
        end
      end

      def track_usage
        @current_api_key&.track_request! if response.successful?
      end

      def paginate(scope)
        per_page = [ (params[:per_page] || 25).to_i, 100 ].min
        per_page = 25 if per_page < 1
        pagy, records = pagy(scope, limit: per_page)
        [pagy, records]
      end

      def pagination_meta(pagy)
        {
          current_page: pagy.page,
          total_pages: pagy.pages,
          total_count: pagy.count,
          per_page: pagy.limit
        }
      end
    end
  end
end
