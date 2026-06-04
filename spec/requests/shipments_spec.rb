require "rails_helper"

RSpec.describe "Shipments (Invoices)", type: :request do
  let(:bakery)    { create(:bakery) }
  let(:user)      { create(:user, bakery: bakery) }
  let(:route)     { create(:route, bakery: bakery) }
  let(:client)    { create(:client, bakery: bakery) }
  let!(:shipment) { create(:shipment, bakery: bakery, client: client, route: route) }

  describe "unauthenticated" do
    it "redirects to sign in" do
      get shipments_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "none permission" do
    before { sign_in create(:user, bakery: bakery, client_permission: "none") }

    it "blocks index" do
      get shipments_path
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end
  end

  describe "read permission" do
    before { sign_in create(:user, bakery: bakery, client_permission: "read") }

    it "allows index" do
      get shipments_path
      expect(response).to be_successful
    end

    it "blocks new" do
      get new_shipment_path
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end

    it "blocks edit" do
      get edit_shipment_path(shipment)
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end
  end

  describe "manage permission" do
    before { sign_in user }

    it "lists shipments" do
      get shipments_path
      expect(response).to be_successful
    end

    it "shows new shipment form" do
      get new_shipment_path
      expect(response).to be_successful
    end

    it "creates a shipment with valid params" do
      params = {
        client_id: client.id,
        route_id: route.id,
        date: Time.zone.today,
      }
      expect {
        post shipments_path, params: { shipment: params }
      }.to change(Shipment, :count).by(1)
      expect(flash[:notice]).to match(/You have created/)
    end

    it "shows edit form" do
      get edit_shipment_path(shipment)
      expect(response).to be_successful
    end

    it "updates a shipment" do
      patch shipment_path(shipment), params: { shipment: { note: "leave at door" } }
      expect(shipment.reload.note).to eq("leave at door")
      expect(flash[:notice]).to match(/You have updated/)
    end
  end

  describe "data scoping" do
    before { sign_in user }

    it "raises RecordNotFound for another bakery's shipment" do
      other = create(:shipment, bakery: create(:bakery))
      expect { get edit_shipment_path(other) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
