require "rails_helper"

RSpec.describe "Api::V1::Orders", type: :request do
  let(:bakery) { create(:bakery) }
  let(:client) { create(:client, bakery: bakery) }
  let(:route)  { create(:route, bakery: bakery) }
  let!(:order) { create(:order, bakery: bakery, client: client, route: route, order_type: "standing") }

  around do |example|
    original_secret = ENV["JWT_SECRET"]
    original_issuer = ENV["JWT_ISSUER"]
    ENV["JWT_SECRET"] = JwtHelpers::JWT_TEST_SECRET
    ENV["JWT_ISSUER"] = JwtHelpers::JWT_TEST_ISSUER
    example.run
  ensure
    ENV["JWT_SECRET"] = original_secret
    ENV["JWT_ISSUER"] = original_issuer
  end

  describe "GET /api/v1/orders" do
    it "returns 401 with no token" do
      get "/api/v1/orders"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns the client's standing order" do
      get "/api/v1/orders", headers: jwt_auth_header(client.id)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["success"]).to be true
    end

    it "does not blow up when product_info is omitted" do
      get "/api/v1/orders", headers: jwt_auth_header(client.id)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["products"]).to be_present
    end
  end

  describe "PATCH /api/v1/orders" do
    it "returns 401 with no token" do
      patch "/api/v1/orders"
      expect(response).to have_http_status(:unauthorized)
    end

    it "updates the standing order's note" do
      patch "/api/v1/orders",
            params: { order: { note: "Ring the bell" } },
            headers: jwt_auth_header(client.id)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["success"]).to be true
      expect(order.reload.note).to eq("Ring the bell")
    end
  end
end
