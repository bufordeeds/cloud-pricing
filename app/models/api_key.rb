class ApiKey < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, inclusion: { in: %w[pending active revoked denied] }

  scope :pending, -> { where(status: "pending") }
  scope :active, -> { where(status: "active") }
  scope :inactive, -> { where(status: %w[revoked denied]) }

  def self.authenticate(token)
    return nil if token.blank?

    digest = Digest::SHA256.hexdigest(token)
    find_by(token_digest: digest, status: "active")
  end

  def self.create_with_token!(attributes)
    token = "cp_#{SecureRandom.hex(32)}"
    api_key = create!(
      **attributes,
      token_digest: Digest::SHA256.hexdigest(token),
      token_prefix: token[0, 11]
    )
    [api_key, token]
  end

  def generate_token!
    token = "cp_#{SecureRandom.hex(32)}"
    update!(
      token_digest: Digest::SHA256.hexdigest(token),
      token_prefix: token[0, 11],
      status: "active",
      approved_at: Time.current
    )
    token
  end

  def deny!(reason = nil)
    update!(status: "denied", notes: reason)
  end

  def revoke!
    update!(status: "revoked", revoked_at: Time.current)
  end

  def track_request!
    update_columns(
      request_count: request_count + 1,
      last_request_at: Time.current
    )
  end

  def active?
    status == "active"
  end

  def pending?
    status == "pending"
  end
end
