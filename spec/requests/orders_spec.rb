require "rails_helper"

# Orders has no show route — index, new, edit, update, copy are the key actions.
RSpec.describe "Orders", type: :request do
  let(:bakery)  { create(:bakery) }
  let(:user)    { create(:user, bakery: bakery) }
  let(:route)   { create(:route, bakery: bakery) }
  let(:client)  { create(:client, bakery: bakery) }
  let!(:order)  { create(:order, bakery: bakery, client: client, route: route) }

  describe "unauthenticated" do
    it "redirects to sign in" do
      get orders_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "none permission" do
    before { sign_in create(:user, bakery: bakery, client_permission: "none") }

    it "blocks index" do
      get orders_path
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end

    it "blocks new" do
      get new_order_path
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end
  end

  describe "read permission" do
    before { sign_in create(:user, bakery: bakery, client_permission: "read") }

    it "allows index" do
      get orders_path
      expect(response).to be_successful
    end

    it "blocks new" do
      get new_order_path
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end

    it "blocks edit" do
      get edit_order_path(order)
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end
  end

  describe "manage permission" do
    before { sign_in user }

    it "lists orders" do
      get orders_path
      expect(response).to be_successful
    end

    it "shows new order form" do
      get new_order_path
      expect(response).to be_successful
    end

    it "creates an order with valid params" do
      # Use a fresh client so there are no existing orders to trigger OverlappingOrdersValidator
      fresh_client = create(:client, bakery: bakery)
      params = {
        order_type: "standing",
        start_date: Time.zone.today.to_s,
        client_id: fresh_client.id,
        route_id: route.id,
      }
      post orders_path, params: { order: params }
      expect(flash[:notice]).to match(/You have created/)
    end

    it "shows edit form" do
      get edit_order_path(order)
      expect(response).to be_successful
    end

    it "updates an order note" do
      patch order_path(order), params: { order: { note: "Ring the bell" } }
      expect(order.reload.note).to eq("Ring the bell")
      expect(flash[:notice]).to match(/You have updated/)
    end
  end

  describe "data scoping" do
    before { sign_in user }

    it "raises RecordNotFound for another bakery's order" do
      other = create(:order, bakery: create(:bakery))
      expect { get edit_order_path(other) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
