class LlmModel < ApplicationRecord
  belongs_to :llm_provider

  validates :name, presence: true
  validates :model_id, presence: true, uniqueness: { scope: [ :llm_provider_id ] }
  validates :input_price_per_mtok, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :output_price_per_mtok, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :by_provider, ->(slugs) {
    return all if slugs.blank?
    joins(:llm_provider).where(llm_providers: { slug: slugs })
  }

  scope :search, ->(query) {
    return all if query.blank?
    where("name ILIKE ?", "%#{sanitize_sql_like(query)}%")
  }

  scope :by_context_window, ->(min, max) {
    scope = all
    scope = scope.where("context_window >= ?", min) if min.present?
    scope = scope.where("context_window <= ?", max) if max.present?
    scope
  }

  scope :sorted_by, ->(field, direction = "asc") {
    direction = direction.to_s.downcase == "desc" ? "desc" : "asc"

    case field.to_s
    when "input_price"
      order(input_price_per_mtok: direction)
    when "output_price"
      order(output_price_per_mtok: direction)
    when "context"
      order(context_window: direction)
    when "name"
      order(name: direction)
    when "blended_price"
      order(Arel.sql("(input_price_per_mtok + output_price_per_mtok) / 2 #{direction}"))
    else
      order(input_price_per_mtok: :asc)
    end
  }

  def capabilities
    caps = []
    caps << "Vision" if supports_vision
    caps << "Tools" if supports_tool_use
    caps << "Thinking" if supports_extended_thinking
    caps
  end

  def blended_price_per_mtok
    (input_price_per_mtok + output_price_per_mtok) / 2
  end

  def cost_per_request(input_tokens: 1000, output_tokens: 1000)
    (input_tokens * input_price_per_mtok / 1_000_000) +
      (output_tokens * output_price_per_mtok / 1_000_000)
  end

  def monthly_cost(requests_per_day: 100, avg_input: 1000, avg_output: 1000)
    cost_per_request(input_tokens: avg_input, output_tokens: avg_output) * requests_per_day * 30
  end
end
