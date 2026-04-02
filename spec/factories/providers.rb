FactoryBot.define do
  factory :provider do
    sequence(:name) { |n| "Provider #{n}" }
    sequence(:slug) { |n| "provider_#{n}" }
    color { "#FF9900" }

    trait :aws do
      name { "AWS" }
      slug { "aws" }
      color { "#FF9900" }
    end

    trait :gcp do
      name { "GCP" }
      slug { "gcp" }
      color { "#4285F4" }
    end

    trait :azure do
      name { "Azure" }
      slug { "azure" }
      color { "#0078D4" }
    end
  end
end
