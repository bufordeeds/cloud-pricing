class ApiKeyMailer < ApplicationMailer
  def approved(api_key, plaintext_token)
    @api_key = api_key
    @token = plaintext_token
    @base_url = "https://cloudpricing.buford.dev"

    mail(
      to: api_key.email,
      subject: "Your CloudPricing API Key"
    )
  end
end
