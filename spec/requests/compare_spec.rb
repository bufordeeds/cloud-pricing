require "rails_helper"

RSpec.describe "Compare", type: :request do
  let(:aws) { create(:provider, :aws) }
  let(:gcp) { create(:provider, :gcp) }

  let!(:instance1) { create(:instance, provider: aws, instance_type: "m5.xlarge", vcpus: 4, memory_gb: 16, price_per_hour: 0.192) }
  let!(:instance2) { create(:instance, provider: gcp, instance_type: "n2-standard-4", vcpus: 4, memory_gb: 16, price_per_hour: 0.194, region: "us-central1") }

  describe "GET /compare" do
    it "compares selected instances" do
      get compare_path(ids: "#{instance1.id},#{instance2.id}")
      expect(response).to have_http_status(:success)
      expect(response.body).to include("m5.xlarge")
      expect(response.body).to include("n2-standard-4")
    end

    it "redirects with fewer than 2 instances" do
      get compare_path(ids: instance1.id.to_s)
      expect(response).to redirect_to(instances_path)
    end
  end
end
