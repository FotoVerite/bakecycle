# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Vendors", type: :system do
  let(:bakery) { create(:bakery) }
  let(:user)   { create(:user, bakery: bakery) }

  before { login_as user, scope: :user }

  describe "create" do
    it "creates a vendor" do
      visit new_vendor_path

      fill_in "Name", with: "Flour Supply Co"
      click_button "Create"

      expect(page).to have_content("You have created Flour Supply Co")
    end
  end

  describe "update" do
    let!(:vendor) { create(:vendor, bakery: bakery, name: "Old Vendor") }

    it "updates a vendor name" do
      visit edit_vendor_path(vendor)

      fill_in "Name", with: "New Vendor"
      click_button "Update"

      expect(page).to have_content("You have updated New Vendor")
    end
  end

  describe "destroy" do
    let!(:vendor) { create(:vendor, bakery: bakery, name: "Temp Vendor") }

    it "deletes a vendor" do
      visit edit_vendor_path(vendor)

      accept_confirm { click_link "Delete" }

      expect(page).to have_content("You have deleted Temp Vendor")
      expect(page).to have_current_path(vendors_path)
    end
  end
end
