require "rails_helper"

RSpec.describe "Instances", type: :request do
  let(:aws) { create(:provider, :aws) }

  before do
    create(:instance, provider: aws, instance_type: "m5.xlarge", vcpus: 4, memory_gb: 16, price_per_hour: 0.192)
    create(:instance, provider: aws, instance_type: "m5.2xlarge", vcpus: 8, memory_gb: 32, price_per_hour: 0.384)
  end

  describe "GET /instances" do
    it "returns a successful response" do
      get instances_path
      expect(response).to have_http_status(:success)
    end

    it "displays instance data" do
      get instances_path
      expect(response.body).to include("m5.xlarge")
      expect(response.body).to include("m5.2xlarge")
    end

    it "filters by search query" do
      get instances_path(q: "2xlarge")
      expect(response.body).to include("m5.2xlarge")
      expect(response.body).not_to include("m5.xlarge\n")
    end

    it "filters by vcpu range" do
      get instances_path(vcpus_min: 6)
      expect(response.body).to include("m5.2xlarge")
    end

    it "sorts by price" do
      get instances_path(sort: "price", direction: "desc")
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /instances/:id" do
    it "shows instance details" do
      instance = Instance.first
      get instance_path(instance)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(instance.instance_type)
    end
  end
end
