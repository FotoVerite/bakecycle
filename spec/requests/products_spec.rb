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

    it "updates a product name" do
      patch product_path(product), params: { product: { name: "Almond Croissant" } }
      expect(product.reload.name).to eq("Almond Croissant")
      expect(flash[:notice]).to match(/You have updated/)
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
end
