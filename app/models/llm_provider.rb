class LlmProvider < ApplicationRecord
  has_many :llm_models, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  def self.seed!
    [
      { name: "Anthropic", slug: "anthropic", color: "#D4A574" },
      { name: "OpenAI", slug: "openai", color: "#10A37F" },
      { name: "Google", slug: "google", color: "#4285F4" },
      { name: "Meta", slug: "meta", color: "#0668E1" },
      { name: "Mistral", slug: "mistral", color: "#F54E42" }
    ].each do |attrs|
      find_or_create_by!(slug: attrs[:slug]) do |p|
        p.name = attrs[:name]
        p.color = attrs[:color]
      end
    end
  end
end
