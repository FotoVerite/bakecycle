require "rails_helper"

RSpec.describe "Api::V1::Accounts", type: :request do
  let(:bakery) { create(:bakery) }
  let!(:client) { create(:client, bakery: bakery) }

  around do |example|
    ClimateControl.module_eval do
      # stub ENV without polluting other tests
    end
    original_secret = ENV["JWT_SECRET"]
    original_issuer = ENV["JWT_ISSUER"]
    ENV["JWT_SECRET"] = JwtHelpers::JWT_TEST_SECRET
    ENV["JWT_ISSUER"] = JwtHelpers::JWT_TEST_ISSUER
    example.run
  ensure
    ENV["JWT_SECRET"] = original_secret
    ENV["JWT_ISSUER"] = original_issuer
  end

  describe "GET /api/v1/account" do
    it "returns 401 with no token" do
      get "/api/v1/account"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns client data with a valid token" do
      get "/api/v1/account", headers: jwt_auth_header(client.id)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["success"]).to be true
      expect(body["client"]["name"]).to eq(client.name)
    end
  end

  describe "PATCH /api/v1/account" do
    it "returns 401 with no token" do
      patch "/api/v1/account"
      expect(response).to have_http_status(:unauthorized)
    end

    it "updates the client and returns success" do
      patch "/api/v1/account",
        params: { client: { name: "Updated Bakery Name" } },
        headers: jwt_auth_header(client.id)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["success"]).to be true
      expect(client.reload.name).to eq("Updated Bakery Name")
    end

    it "returns success false when update fails" do
      # name has presence validation — blank should fail
      patch "/api/v1/account",
        params: { client: { name: "" } },
        headers: jwt_auth_header(client.id)
      body = JSON.parse(response.body)
      expect(body["success"]).to be false
    end
  end
end
