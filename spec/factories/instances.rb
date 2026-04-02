FactoryBot.define do
  factory :instance do
    provider
    sequence(:instance_type) { |n| "m5.instance#{n}" }
    family { "General Purpose" }
    vcpus { 4 }
    memory_gb { 16.0 }
    price_per_hour { 0.192 }
    region { "us-east-1" }
    operating_system { "Linux" }
    raw_attributes { {} }
  end
end
