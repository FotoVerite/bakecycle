# frozen_string_literal: true

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
        route_id: route.id
      }
      post orders_path, params: { order: params }
      expect(flash[:notice]).to match(/You have created/)
    end

    it "shows edit form" do
      get edit_order_path(order)
      expect(response).to be_successful
    end

    it "links back to the order client on the edit page" do
      get edit_order_path(order)

      expect(response).to be_successful
      expect(response.body).to include("href=\"#{client_path(client)}\"")
    end

    it "updates an order note" do
      patch order_path(order), params: { order: { note: "Ring the bell" } }
      expect(order.reload.note).to eq("Ring the bell")
      expect(flash[:notice]).to match(/You have updated/)
    end

    it "deletes a marked cancellation override without creating a shipment or production run" do
      delivery_date = Time.zone.today + 1.day
      cancellation_client = create(:client, bakery: bakery)
      product = create(:product, bakery: bakery)
      standing = create(
        :order,
        bakery: bakery,
        client: cancellation_client,
        route: route,
        start_date: Time.zone.today - 1.week,
        order_item_count: 0
      )
      create(:order_item, bakery: bakery, order: standing, product: product, daily_item_count: 1)
      cancellation = create(
        :temporary_order,
        bakery: bakery,
        client: cancellation_client,
        route: route,
        start_date: delivery_date,
        cancellation_override: true,
        order_item_count: 0
      )
      create(:order_item, bakery: bakery, order: cancellation, product: product, daily_item_count: 0)

      expect(ProductionRunService).not_to receive(:new)

      expect {
        delete order_path(cancellation)
      }.not_to change(Shipment, :count)

      expect(Order).not_to exist(cancellation.id)
      expect(response).to redirect_to(client_path(cancellation_client))
    end

    it "does not restore a shipment when deleting an ordinary temporary order" do
      delivery_date = Time.zone.today + 1.day
      temporary = create(
        :temporary_order,
        bakery: bakery,
        client: client,
        route: route,
        start_date: delivery_date,
        order_item_count: 0
      )

      expect {
        delete order_path(temporary)
      }.not_to change(Shipment, :count)

      expect(Order).not_to exist(temporary.id)
      expect(response).to redirect_to(client_path(client))
    end

    it "identifies a cancellation override and explains that deleting it removes the cancellation" do
      cancellation = create(
        :temporary_order,
        bakery: bakery,
        client: client,
        route: route,
        start_date: Time.zone.today + 1.day,
        cancellation_override: true
      )

      get edit_order_path(cancellation)

      expect(response.body).to include("Scheduled delivery cancelled for")
      expect(response.body).to include("remove this cancellation for")
    end

    it "identifies cancellation overrides and filters to them on the orders index" do
      cancellation = create(
        :temporary_order,
        bakery: bakery,
        client: create(:client, bakery: bakery),
        route: route,
        start_date: Time.zone.today + 1.day,
        cancellation_override: true
      )

      get orders_path, params: { search: { status: "cancellation_override" } }

      expect(response.body).to include("Cancellation overrides")
      expect(response.body).to include("class=\"order-cancellation-status\"")
      expect(response.body).to include("Cancellation</span>")
      expect(response.body).to include("href=\"#{edit_order_path(cancellation)}\"")
      expect(response.body).not_to include("href=\"#{edit_order_path(order)}\"")
    end
  end

  describe "data scoping" do
    before { sign_in user }

    it "redirects to index for another bakery's order" do
      other = create(:order, bakery: create(:bakery))
      get edit_order_path(other)
      expect(response).to redirect_to(orders_path)
      expect(flash[:alert]).to eq("That record no longer exists.")
    end
  end
end
