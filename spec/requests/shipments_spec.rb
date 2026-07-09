# frozen_string_literal: true

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
      expect(response.body).to include("Find invoices by number, client, product, or delivery date.")
      expect(response.body).to include("1 invoice")
      expect(response.body).to include("Export invoice PDFs")
      expect(response.body).to include("Export QuickBooks IIF")
    end

    it "shows filter feedback and recovery when no invoices match" do
      get shipments_path, params: { search: { sequence_number: "missing" } }

      expect(response).to be_successful
      expect(response.body).to include("0 invoices")
      expect(response.body).to include("No invoices match these filters")
      expect(response.body).to include("Reset filters")
      expect(response.body).not_to include("Export invoice PDFs")
    end

    it "warns about duplicate invoices before exports and links to review them" do
      shipment.update!(date: Time.zone.today)
      duplicate = create(
        :shipment,
        bakery: bakery,
        client: client,
        route: route,
        date: shipment.date
      )

      get shipments_path

      expect(response).to be_successful
      expect(response.body.index("duplicate invoices")).to be < response.body.index("Export scope")
      expect(response.body).to include("2 flagged invoices will be included in exports")
      expect(response.body).to include(edit_shipment_path(shipment))
      expect(response.body).to include(edit_shipment_path(duplicate))
      expect(response.body).to include("Review invoice")
    end

    it "describes the active export criteria" do
      product = create(:product, bakery: bakery)
      shipment.update!(date: Date.new(2026, 6, 15))
      create(:shipment_item, bakery: bakery, shipment: shipment, product: product)

      get shipments_path, params: {
        search: {
          client_id: [client.id],
          product_id: [product.id],
          date_from: "2026-06-01",
          date_to: "2026-06-30"
        }
      }

      expect(response).to be_successful
      expect(response.body).to include("Clients: #{ERB::Util.html_escape(client.name)}")
      expect(response.body).to include("Products: #{ERB::Util.html_escape(product.name)}")
      expect(response.body).to include("Delivery dates: June 1, 2026 to June 30, 2026")
    end

    it "shows new shipment form" do
      get new_shipment_path
      expect(response).to be_successful
    end

    it "creates a shipment with valid params" do
      params = {
        client_id: client.id,
        route_id: route.id,
        date: Time.zone.today
      }
      expect {
        post shipments_path, params: { shipment: params }
      }.to change(Shipment, :count).by(1)
      expect(flash[:notice]).to match(/You have created/)
    end

    it "creates a shipment with nested product items" do
      product = create(:product, bakery: bakery, base_price: 3.25, total_lead_days: 1)
      params = {
        client_id: client.id,
        route_id: route.id,
        date: Time.zone.today,
        shipment_items_attributes: {
          "0" => {
            product_id: product.id,
            product_quantity: 4,
            product_price: 3.25
          }
        }
      }

      expect {
        post shipments_path, params: { shipment: params }
      }.to change(ShipmentItem, :count).by(1)

      shipment_item = Shipment.last.shipment_items.first
      expect(shipment_item.product_name).to eq(product.name)
      expect(shipment_item.product_quantity).to eq(4)
      expect(shipment_item.product_price).to eq(3.25)
    end

    it "shows edit form" do
      get edit_shipment_path(shipment)
      expect(response).to be_successful
    end

    it "links back to the invoice client on the edit page" do
      get edit_shipment_path(shipment)

      expect(response).to be_successful
      expect(response.body).to include("href=\"#{client_path(client)}\"")
    end

    it "updates a shipment" do
      patch shipment_path(shipment), params: { shipment: { note: "leave at door" } }
      expect(shipment.reload.note).to eq("leave at door")
      expect(flash[:notice]).to match(/You have updated/)
    end
  end

  describe "data scoping" do
    before { sign_in user }

    it "redirects to index for another bakery's shipment" do
      other = create(:shipment, bakery: create(:bakery))
      get edit_shipment_path(other)
      expect(response).to redirect_to(shipments_path)
      expect(flash[:alert]).to eq("That record no longer exists.")
    end

    it "does not list another bakery's invoices on the index" do
      other = create(:shipment, bakery: create(:bakery))
      get shipments_path
      expect(response.body).to include(edit_shipment_path(shipment))
      expect(response.body).not_to include(edit_shipment_path(other))
    end
  end
end
