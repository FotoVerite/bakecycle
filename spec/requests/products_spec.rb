# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Products", type: :request do
  let(:bakery)   { create(:bakery) }
  let(:user)     { create(:user, bakery: bakery) }
  let!(:product) { create(:product, bakery: bakery) }

  describe "unauthenticated" do
    it "redirects to sign in" do
      get products_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "none permission" do
    before { sign_in create(:user, bakery: bakery, product_permission: "none") }

    it "blocks index" do
      get products_path
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end

    # policy_scope returns scope.none → RecordNotFound caught by ApplicationController → redirect
    it "redirects to index when scope blocks access" do
      get product_path(product)
      expect(response).to redirect_to(products_path)
      expect(flash[:alert]).to eq("That record no longer exists.")
    end
  end

  describe "read permission" do
    before { sign_in create(:user, bakery: bakery, product_permission: "read") }

    it "allows index" do
      get products_path
      expect(response).to be_successful
    end

    it "blocks edit" do
      get edit_product_path(product)
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end

    it "blocks create" do
      post products_path, params: { product: { name: "Denied" } }
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end
  end

  describe "manage permission" do
    before { sign_in user }

    it "lists products" do
      get products_path
      expect(response).to be_successful
    end

    it "filters by name" do
      matching = create(:product, bakery: bakery, name: "Sourdough Boule")
      create(:product, bakery: bakery, name: "Baguette")

      get products_path, params: { name: "sourdough" }

      expect(response.body).to include(matching.name)
      expect(response.body).not_to include("Baguette")
    end

    it "targets product table action links at the top frame" do
      get products_path

      expect(response.body).to match(%r{<a[^>]+data-turbo-frame="_top"[^>]+href="/products/#{product.id}"})
      expect(response.body).to match(%r{<a[^>]+data-turbo-frame="_top"[^>]+href="/products/#{product.id}/edit"})
      expect(response.body).to match(%r{<a[^>]+data-turbo-frame="_top"[^>]+href="/products/#{product.id}/papertrail"})
    end

    it "shows a product" do
      get product_path(product)
      expect(response).to be_successful
    end

    it "shows new product form" do
      get new_product_path
      expect(response).to be_successful
    end

    it "creates a product with valid params" do
      params = attributes_for(:product).except(:bakery)
      expect {
        post products_path, params: { product: params }
      }.to change(Product, :count).by(1)
      expect(flash[:notice]).to match(/You have created/)
    end

    it "shows edit form" do
      get edit_product_path(product)
      expect(response).to be_successful
    end

    it "renders persisted price variant ids on the edit form" do
      price_variant = create(:price_variant, product: product, client: nil)

      get edit_product_path(product)

      expect(response.body).to include(%(name="product[price_variants_attributes][0][id]"))
      expect(response.body).to include(%(value="#{price_variant.id}"))
    end

    it "offers active clients as override choices, plus any inactive client an existing override "\
       "already references (so its select doesn't silently lose its value)" do
      create(:client, bakery: bakery, name: "Active Client", active: true)
      referenced_inactive_client = create(:client, bakery: bakery, name: "Referenced Inactive Client",
                                                   active: false)
      create(:client, bakery: bakery, name: "Unrelated Inactive Client", active: false)
      create(:price_variant, product: product, client: referenced_inactive_client, quantity: 5)

      get edit_product_path(product)

      # The full client list is rendered once into the shared options cache (read by
      # tom-select), not repeated inline per <select> -- see products/_form.html.erb.
      clients_json = response.body[%r{id="product-clients-options">(.*?)</script>}m, 1]
      client_names = JSON.parse(clients_json).pluck("text")

      expect(client_names).to include("Active Client", "Referenced Inactive Client")
      expect(client_names).to_not include("Unrelated Inactive Client")
    end

    it "updates a product name" do
      patch product_path(product), params: { product: { name: "Almond Croissant" } }
      expect(product.reload.name).to eq("Almond Croissant")
      expect(flash[:notice]).to match(/You have updated/)
    end

    it "updates product tray metadata" do
      patch product_path(product), params: { product: { pieces_per_tray: 60 } }
      expect(product.reload.pieces_per_tray).to eq(60)
      expect(flash[:notice]).to match(/You have updated/)
    end

    it "updates existing price variants in place" do
      price_variant = create(:price_variant, product: product, client: nil, quantity: 1, price: 3)

      patch product_path(product), params: {
        product: {
          price_variants_attributes: {
            "0" => {
              id: price_variant.id,
              client_id: "",
              quantity: 24,
              price: 4.25
            }
          }
        }
      }

      expect(product.price_variants.count).to eq(1)
      expect(price_variant.reload.quantity).to eq(24)
      expect(price_variant.price).to eq(4.25)
    end

    it "adds a bake lead day override for a client without disturbing existing per-client " \
       "price variants (reproduces product 26804's shape: one all-clients qty-1 variant " \
       "plus 36 per-client qty-1 variants)" do
      all_clients_variant = create(:price_variant, product: product, client: nil, quantity: 1, price: 0)
      clients = create_list(:client, 36, bakery: bakery)
      smith_st = clients.first
      per_client_variants = clients.map do |c|
        create(:price_variant, product: product, client: c, quantity: 1, price: 2.5)
      end

      # Simulate the real form: every currently-rendered price_variant row is resubmitted
      # unchanged (Rails nested attributes re-sends the whole fields_for collection, not
      # just what the user actually touched), plus one new bake_lead_day_variant.
      price_variants_attributes = ([all_clients_variant] + per_client_variants).each_with_index.to_h do |pv, i|
        [i.to_s, { id: pv.id, client_id: pv.client_id, quantity: pv.quantity, price: pv.price }]
      end

      patch product_path(product), params: {
        product: {
          price_variants_attributes: price_variants_attributes,
          bake_lead_day_variants_attributes: {
            "0" => { client_id: smith_st.id, bake_lead_days: 1 }
          }
        }
      }

      expect(product.errors.full_messages).to eq([])
      expect(response).to redirect_to(edit_product_path(product))
      expect(product.reload.bake_lead_day_variants.count).to eq(1)
      expect(product.bake_lead_day_variants.first.client_id).to eq(smith_st.id)
      expect(product.price_variants.where(client_id: nil).count).to eq(1)
    end

    it "silently drops an unused new bake lead day override row (no client picked) instead " \
       "of erroring, even though the field now defaults to 0 rather than blank" do
      patch product_path(product), params: {
        product: {
          bake_lead_day_variants_attributes: {
            "0" => { client_id: "", bake_lead_days: "0" }
          }
        }
      }

      expect(product.errors.full_messages).to eq([])
      expect(response).to redirect_to(edit_product_path(product))
      expect(product.reload.bake_lead_day_variants.count).to eq(0)
    end

    it "shows product report source choices" do
      get product_totals_report_products_path

      expect(response).to be_successful
      expect(response.body).to include("Export Product Totals")
      expect(response.body).to include(%(name="end_date"))
      expect(response.body).to include(%(value="#{(Time.zone.today + 6.days).strftime('%Y-%m-%d')}"))
      expect(response.body).to include(">Day</button>")
      expect(response.body).not_to include("Orders are for planning")
      expect(response.body).to include(%(action="#{export_product_totals_products_path}"))
      expect(response.body).to include("Use")
      expect(response.body).to include("Orders")
      expect(response.body).to include("Standing and temp orders for planning.")
      expect(response.body).to include("Created shipments")
      expect(response.body).to include("Invoices and shipments already generated.")
    end

    it "shows the plan vs created comparison" do
      croissant = create(:product, bakery: bakery, name: "Croissant")
      shipment = create(:shipment, bakery: bakery, date: Time.zone.today)
      create(:shipment_item, bakery: bakery, shipment: shipment, product: croissant, product_quantity: 55)

      get product_totals_comparison_products_path

      expect(response).to be_successful
      expect(response.body).to include("Plan vs Created")
      expect(response.body).to include("Croissant")
      expect(response.body).to include("Only differences")
    end

    it "compares a snapshot as the baseline" do
      croissant = create(:product, bakery: bakery, name: "Croissant")
      order = create(:order, bakery: bakery, start_date: Time.zone.today, order_item_count: 0)
      create(:order_item, bakery: bakery, order: order, product: croissant, daily_item_count: 40)
      snapshot = ProductTotalsSnapshot.capture!(
        bakery: bakery, start_date: Time.zone.today, end_date: Time.zone.today,
        source: "order_projection", label: "nightly"
      )

      get product_totals_comparison_products_path(
        date: Time.zone.today.iso8601,
        end_date: Time.zone.today.iso8601,
        baseline: "snapshot_#{snapshot.id}",
        compare: "orders",
        diff_only: "0"
      )

      expect(response).to be_successful
      expect(response.body).to include("snapshot (orders)")
      expect(response.body).to include("Croissant")
    end

    it "starts the product totals export" do
      file_export = create(:file_export, bakery: bakery)

      allow(ExporterJob).to receive(:create).and_return(file_export)

      get export_product_totals_products_path(
        date: "2026-06-03",
        end_date: "2026-06-09",
        source: "generated_invoices"
      )

      expect(ExporterJob).to have_received(:create).with(
        user,
        bakery,
        have_attributes(
          end_date: Date.new(2026, 6, 9),
          source: "generated_invoices"
        )
      )
      expect(response).to redirect_to(file_export)
    end

    it "soft-deletes an inactive product" do
      product.update!(inactive: true)
      delete product_path(product)
      expect(product.reload.removed).to be true
    end
  end

  describe "data scoping" do
    before { sign_in user }

    it "redirects to index for another bakery's product" do
      other = create(:product, bakery: create(:bakery))
      get product_path(other)
      expect(response).to redirect_to(products_path)
      expect(flash[:alert]).to eq("That record no longer exists.")
    end
  end

  describe "orders pagination" do
    before do
      sign_in user
      # will_paginate bakes per_page onto each model class as a fixed ivar at load
      # time (see WillPaginate::PerPage#inherited) -- setting the WillPaginate.per_page
      # global at runtime doesn't retroactively change Order.per_page, so the model's
      # own per_page has to be stubbed directly for this to actually take effect.
      @original_per_page = Order.per_page
      Order.per_page = 2
    end

    after { Order.per_page = @original_per_page }

    def create_orders_in_use(count)
      client = create(:client, bakery: bakery)
      create_list(:order, count, :active, bakery: bakery, client: client).each do |order|
        create(:order_item, order: order, product: product, bakery: bakery)
      end
    end

    it "paginates the orders table on the product page instead of loading them all" do
      create_orders_in_use(3)

      get product_path(product)
      expect(response.body.scan(/js-clickable-row/).count).to eq(2)

      get product_path(product), params: { page: 2 }
      expect(response.body.scan(/js-clickable-row/).count).to eq(1)
    end

    it "paginates the dedicated product orders page the same way" do
      create_orders_in_use(3)

      get orders_product_path(product)
      expect(response.body.scan(/js-clickable-row/).count).to eq(2)

      get orders_product_path(product), params: { page: 2 }
      expect(response.body.scan(/js-clickable-row/).count).to eq(1)
    end
  end
end
