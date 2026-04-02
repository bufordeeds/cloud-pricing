class Instance < ApplicationRecord
  belongs_to :provider

  validates :instance_type, presence: true
  validates :vcpus, presence: true, numericality: { greater_than: 0 }
  validates :memory_gb, presence: true, numericality: { greater_than: 0 }
  validates :price_per_hour, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :region, presence: true
  validates :instance_type, uniqueness: { scope: [:provider_id, :region] }

  scope :by_provider, ->(slugs) {
    return all if slugs.blank?
    joins(:provider).where(providers: { slug: slugs })
  }

  scope :by_vcpus, ->(min, max) {
    scope = all
    scope = scope.where("vcpus >= ?", min) if min.present?
    scope = scope.where("vcpus <= ?", max) if max.present?
    scope
  }

  scope :by_memory, ->(min, max) {
    scope = all
    scope = scope.where("memory_gb >= ?", min) if min.present?
    scope = scope.where("memory_gb <= ?", max) if max.present?
    scope
  }

  scope :by_family, ->(family) {
    return all if family.blank?
    where(family: family)
  }

  scope :search, ->(query) {
    return all if query.blank?
    where("instance_type ILIKE ?", "%#{sanitize_sql_like(query)}%")
  }

  scope :sorted_by, ->(field, direction = "asc") {
    direction = direction.to_s.downcase == "desc" ? "desc" : "asc"

    case field.to_s
    when "price"
      order(price_per_hour: direction)
    when "vcpus"
      order(vcpus: direction)
    when "memory"
      order(memory_gb: direction)
    when "price_per_vcpu"
      order(Arel.sql("price_per_hour / vcpus #{direction}"))
    when "price_per_gb"
      order(Arel.sql("price_per_hour / memory_gb #{direction}"))
    when "instance_type"
      order(instance_type: direction)
    else
      order(price_per_hour: :asc)
    end
  }

  def monthly_cost
    price_per_hour * 730
  end

  def price_per_vcpu
    return 0 if vcpus.zero?
    price_per_hour / vcpus
  end

  def price_per_gb_memory
    return 0 if memory_gb.zero?
    price_per_hour / memory_gb
  end
end
