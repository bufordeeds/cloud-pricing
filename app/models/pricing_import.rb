class PricingImport < ApplicationRecord
  belongs_to :provider

  scope :recent, -> { order(created_at: :desc) }

  def duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end

  def mark_running!
    update!(status: "running", started_at: Time.current)
  end

  def mark_completed!(count)
    update!(status: "completed", records_imported: count, completed_at: Time.current)
  end

  def mark_failed!(message)
    update!(status: "failed", error_message: message, completed_at: Time.current)
  end
end
