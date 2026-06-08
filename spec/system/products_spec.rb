# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Products", type: :system do
  let(:bakery) { create(:bakery) }
  let(:user)   { create(:user, bakery: bakery) }

  before { login_as user, scope: :user }

  describe "create" do
    it "creates a product with valid params" do
      visit new_product_path

      fill_in "Name", with: "Test Sourdough"
      select "bread", from: "Product type"
      fill_in "Weight", with: "1.5"
      fill_in "Base price", with: "4.50"
      click_button "Create"

      expect(page).to have_content("You have created Test Sourdough")
    end

    it "shows errors with missing name" do
      visit new_product_path

      select "bread", from: "Product type"
      fill_in "Weight", with: "1.5"
      fill_in "Base price", with: "4.50"
      click_button "Create"

      expect(page).to have_content("can't be blank")
    end

    it "accepts decimal base price" do
      visit new_product_path

      fill_in "Name", with: "Decimal Price Product"
      select "cookie", from: "Product type"
      fill_in "Weight", with: "0.5"
      fill_in "Base price", with: "2.75"
      click_button "Create"

      expect(page).to have_content("You have created Decimal Price Product")
      expect(Product.find_by(name: "Decimal Price Product").base_price).to eq(2.75)
    end
  end

  describe "update" do
    let!(:product) { create(:product, bakery: bakery, name: "Original Name") }

    it "updates a product name" do
      visit edit_product_path(product)

      fill_in "Name", with: "Updated Name"
      click_button "Update"

      expect(page).to have_content("You have updated Updated Name")
    end

    it "shows errors with blank name" do
      visit edit_product_path(product)

      fill_in "Name", with: ""
      click_button "Update"

      expect(page).to have_content("can't be blank")
    end
  end

  describe "destroy" do
    let!(:product) { create(:product, bakery: bakery, inactive: true) }

    it "soft-deletes an inactive product" do
      visit edit_product_path(product)

      accept_confirm { click_link "Delete" }

      expect(page).to have_content("You have deleted #{product.name}")
      expect(page).to have_current_path(products_path)
      expect(product.reload.removed).to be true
    end
  end
end
