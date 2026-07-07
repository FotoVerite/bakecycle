# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Shipments", type: :system do
  let(:bakery) { create(:bakery) }
  let(:user)   { create(:user, bakery: bakery) }
  let!(:client) { create(:client, bakery: bakery) }
  let!(:route)  { create(:route, bakery: bakery) }

  before { login_as user, scope: :user }

  describe "create" do
    it "creates a shipment with valid params" do
      visit new_shipment_path

      select client.name, from: "Client"
      fill_in "Invoice Date", with: "2026-06-15"
      select route.name, from: "Route"
      click_button "Create"

      expect(page).to have_content("You have created an invoice for #{client.name}")
    end

    it "shows errors with missing client" do
      visit new_shipment_path

      fill_in "Invoice Date", with: "2026-06-15"
      select route.name, from: "Route"
      click_button "Create"

      expect(page).to have_content("can't be blank")
    end
  end

  describe "update" do
    let!(:shipment) { create(:shipment, bakery: bakery, client: client, route: route) }

    it "updates a shipment note" do
      visit edit_shipment_path(shipment)

      fill_in "Special Notes", with: "Updated note"
      click_button "Update"

      expect(page).to have_content("You have updated the invoice for #{client.name}")
    end
  end

  describe "destroy" do
    let!(:shipment) { create(:shipment, bakery: bakery, client: client, route: route) }

    it "deletes a shipment" do
      visit edit_shipment_path(shipment)

      accept_confirm { click_link "Delete" }

      expect(page).to have_content("You have deleted the invoice for #{client.name}")
      expect(page).to have_current_path(client_path(client))
    end
  end
end
