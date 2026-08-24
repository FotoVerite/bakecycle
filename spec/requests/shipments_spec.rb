# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Shipments (Invoices)", type: :request do
  let(:bakery)    { create(:bakery) }
  let(:user)      { create(:user, bakery: bakery) }
  let(:route)     { create(:route, bakery: bakery) }
  let(:client)    { create(:client, bakery: bakery, name: "Jane's Café & Market") }
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

    describe "batch export limit" do
      before do
        allow_any_instance_of(ShipmentsController)
          .to receive(:batch_export_invoice_count)
          .and_return(1_001)
      end

      %i[export_pdf export_csv export_iif].each do |export_action|
        it "shows an error box for an oversized #{export_action.to_s.humanize.downcase} request" do
          expect(ExporterJob).not_to receive(:create)

          get public_send("#{export_action}_shipments_path"),
              headers: { "Accept" => Mime[:turbo_stream].to_s }

          expect(response).to be_successful
          expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
          expect(response.body).to include('target="flash_messages"')
          expect(response.body).to include(
            "This export contains 1,001 invoices. Narrow the filters to 1,000 or fewer and try again."
          )
        end
      end

      it "redirects with the same error for a non-Turbo request" do
        expect(ExporterJob).not_to receive(:create)

        get export_pdf_shipments_path

        expect(response).to redirect_to(shipments_path)
        expect(flash[:alert]).to eq(
          "This export contains 1,001 invoices. Narrow the filters to 1,000 or fewer and try again."
        )
      end
    end

    it "allows a batch export when exactly 1,000 invoices match" do
      allow_any_instance_of(ShipmentsController)
        .to receive(:batch_export_invoice_count)
        .and_return(1_000)
      file_export = create(:file_export, bakery: bakery, user: user)
      allow(ExporterJob).to receive(:create).and_return(file_export)

      get export_pdf_shipments_path

      expect(ExporterJob).to have_received(:create)
      expect(response).to redirect_to(file_export)
    end

    it "prepends the client name to an individual packing slip filename" do
      allow_any_instance_of(PackingSlipsPdf).to receive(:render).and_return("pdf")

      get packing_slip_shipment_path(shipment)

      expect(response.headers["Content-Disposition"]).to include(
        "Jane-s-Cafe-Market-#{bakery.name.parameterize}-Packing-Slip-#{shipment.invoice_number}.pdf"
      )
    end

    it "prepends the client name to an individual QuickBooks filename" do
      allow_any_instance_of(InvoicesIif).to receive(:generate).and_return("iif")

      get invoice_iif_shipment_path(shipment)

      expect(response.headers["Content-Disposition"]).to include(
        "Jane-s-Cafe-Market-bakecycle-quickbook-export.iif"
      )
    end

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

    it "banners an invoice generated from a sample order" do
      order = create(:order, bakery: bakery, client: client, route: route, order_type: "sample")
      sample_shipment = create(:shipment, bakery: bakery, client: client, route: route, order: order)

      get edit_shipment_path(sample_shipment)

      expect(response).to be_successful
      expect(response.body).to include("sample-order-notice")
      expect(response.body).to include("Sample order")
      expect(response.body).to include("No charge")
    end

    it "hides the whole prices section on a sample order's invoice" do
      order = create(:order, bakery: bakery, client: client, route: route, order_type: "sample")
      sample_shipment = create(:shipment, bakery: bakery, client: client, route: route, order: order)

      get edit_shipment_path(sample_shipment)

      expect(response).to be_successful
      expect(response.body).to_not include("discount-panel")
      expect(response.body).to_not include("Sub-total:")
      expect(response.body).to_not include("Total Price:")
    end

    it "shows the prices section on a normal invoice" do
      get edit_shipment_path(shipment)

      expect(response).to be_successful
      expect(response.body).to include("discount-panel")
      expect(response.body).to include("Total Price:")
    end

    it "renders a readonly $0 price on every line of a sample order's invoice" do
      product = create(:product, bakery: bakery, base_price: 12)
      order = create(:order, bakery: bakery, client: client, route: route, order_type: "sample")
      sample_shipment = create(:shipment, bakery: bakery, client: client, route: route, order: order)
      create(:shipment_item, bakery: bakery, shipment: sample_shipment, product: product, product_price: 0)

      get edit_shipment_path(sample_shipment)

      expect(response).to be_successful
      price_input = response.body[/<input[^>]*product_price_input[^>]*>/]
      expect(price_input).to include('readonly="readonly"')
      expect(price_input).to include('value="0"')
    end

    it "keeps prices editable on a normal invoice" do
      create(:shipment_item, bakery: bakery, shipment: shipment)

      get edit_shipment_path(shipment)

      expect(response).to be_successful
      expect(response.body[/<input[^>]*product_price_input[^>]*>/]).to_not include("readonly")
    end

    it "does not banner an invoice with no sample order behind it" do
      get edit_shipment_path(shipment)

      expect(response).to be_successful
      expect(response.body).to_not include("sample-order-notice")
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
