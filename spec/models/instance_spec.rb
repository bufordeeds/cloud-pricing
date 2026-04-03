require "rails_helper"

RSpec.describe Instance, type: :model do
  let(:aws) { create(:provider, :aws) }
  let(:gcp) { create(:provider, :gcp) }

  describe "validations" do
    it "requires instance_type, vcpus, memory_gb, and price_per_hour" do
      instance = Instance.new
      expect(instance).not_to be_valid
      expect(instance.errors[:instance_type]).to be_present
      expect(instance.errors[:vcpus]).to be_present
      expect(instance.errors[:memory_gb]).to be_present
      expect(instance.errors[:price_per_hour]).to be_present
    end

    it "enforces uniqueness of instance_type per provider and region" do
      create(:instance, provider: aws, instance_type: "m5.xlarge", region: "us-east-1")
      duplicate = build(:instance, provider: aws, instance_type: "m5.xlarge", region: "us-east-1")
      expect(duplicate).not_to be_valid
    end
  end

  describe "scopes" do
    before do
      @aws_general = create(:instance, provider: aws, instance_type: "m5.xlarge",
        vcpus: 4, memory_gb: 16, price_per_hour: 0.192, family: "General Purpose")
      @aws_compute = create(:instance, provider: aws, instance_type: "c5.xlarge",
        vcpus: 4, memory_gb: 8, price_per_hour: 0.170, family: "Compute Optimized")
      @gcp_general = create(:instance, provider: gcp, instance_type: "n2-standard-4",
        vcpus: 4, memory_gb: 16, price_per_hour: 0.194, family: "General Purpose", region: "us-central1")
      @aws_large = create(:instance, provider: aws, instance_type: "m5.4xlarge",
        vcpus: 16, memory_gb: 64, price_per_hour: 0.768, family: "General Purpose")
    end

    it "filters by provider" do
      results = Instance.by_provider([ "aws" ])
      expect(results).to include(@aws_general, @aws_compute, @aws_large)
      expect(results).not_to include(@gcp_general)
    end

    it "filters by vcpu range" do
      results = Instance.by_vcpus(8, 32)
      expect(results).to include(@aws_large)
      expect(results).not_to include(@aws_general)
    end

    it "filters by memory range" do
      results = Instance.by_memory(10, 20)
      expect(results).to include(@aws_general, @gcp_general)
      expect(results).not_to include(@aws_compute, @aws_large)
    end

    it "filters by family" do
      results = Instance.by_family("Compute Optimized")
      expect(results).to include(@aws_compute)
      expect(results).not_to include(@aws_general)
    end

    it "searches by instance type" do
      results = Instance.search("m5")
      expect(results).to include(@aws_general, @aws_large)
      expect(results).not_to include(@aws_compute, @gcp_general)
    end

    it "sorts by price" do
      results = Instance.sorted_by("price", "asc")
      expect(results.first).to eq(@aws_compute)
    end

    it "sorts by price_per_vcpu" do
      results = Instance.sorted_by("price_per_vcpu", "asc")
      prices = results.map { |i| i.price_per_hour / i.vcpus }
      expect(prices).to eq(prices.sort)
    end

    it "returns all when filters are blank" do
      expect(Instance.by_provider(nil).count).to eq(4)
      expect(Instance.by_vcpus(nil, nil).count).to eq(4)
      expect(Instance.by_memory(nil, nil).count).to eq(4)
      expect(Instance.by_family(nil).count).to eq(4)
      expect(Instance.search(nil).count).to eq(4)
    end
  end

  describe "#monthly_cost" do
    it "calculates based on 730 hours" do
      instance = build(:instance, price_per_hour: 0.10)
      expect(instance.monthly_cost).to eq(73.0)
    end
  end

  describe "#price_per_vcpu" do
    it "divides price by vcpus" do
      instance = build(:instance, price_per_hour: 0.192, vcpus: 4)
      expect(instance.price_per_vcpu).to eq(0.048)
    end
  end
end
