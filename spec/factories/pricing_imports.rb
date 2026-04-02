FactoryBot.define do
  factory :pricing_import do
    provider
    status { "pending" }
    records_imported { 0 }
  end
end
