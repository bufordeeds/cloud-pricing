class ApiKeyMailer < ApplicationMailer
  ADMIN_EMAIL = "hello@buford.dev"

  def approved(api_key, plaintext_token)
    @api_key = api_key
    @token = plaintext_token
    @base_url = "https://cloudpricing.buford.dev"

    mail(
      to: api_key.email,
      subject: "Your CloudPricing API Key"
    )
  end

  def new_request(api_key)
    @api_key = api_key
    @admin_url = "https://cloudpricing.buford.dev/admin/api_keys"

    mail(
      to: ADMIN_EMAIL,
      subject: "New API key request from #{api_key.name}"
    )
  end
end
