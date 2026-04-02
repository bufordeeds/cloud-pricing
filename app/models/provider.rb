class Provider < ApplicationRecord
  has_many :instances, dependent: :destroy
  has_many :pricing_imports, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  def self.seed!
    [
      { name: "AWS", slug: "aws", color: "#FF9900" },
      { name: "GCP", slug: "gcp", color: "#4285F4" },
      { name: "Azure", slug: "azure", color: "#0078D4" }
    ].each do |attrs|
      find_or_create_by!(slug: attrs[:slug]) do |p|
        p.name = attrs[:name]
        p.color = attrs[:color]
      end
    end
  end
end
