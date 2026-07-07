# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Orders", type: :system do
  let(:bakery) { create(:bakery) }
  let(:user)   { create(:user, bakery: bakery) }
  let!(:client) { create(:client, bakery: bakery) }
  let!(:route)  { create(:route, bakery: bakery) }

  before { login_as user, scope: :user }

  describe "create" do
    it "creates a standing order with valid params" do
      visit new_order_path

      select client.name, from: "Client"
      choose "Standing"
      fill_in "Start date", with: "2026-06-16"
      select route.name, from: "Route"
      click_button "Create"

      expect(page).to have_content("order for #{client.name}")
    end

    it "shows errors with missing client" do
      visit new_order_path

      choose "Standing"
      fill_in "Start date", with: "2026-06-16"
      select route.name, from: "Route"
      click_button "Create"

      expect(page).to have_content("can't be blank")
    end
  end

  describe "update" do
    let!(:order) { create(:order, bakery: bakery, client: client, route: route) }

    it "updates an order note" do
      visit edit_order_path(order)

      fill_in "Note", with: "Updated note"
      click_button "Update"

      expect(page).to have_content("You have updated the")
    end
  end

  describe "destroy" do
    let!(:order) { create(:order, bakery: bakery, client: client, route: route) }

    it "deletes an order" do
      visit edit_order_path(order)

      accept_confirm { click_link "Delete" }

      expect(page).to have_content("You have deleted")
      expect(page).to have_current_path(client_path(client))
    end
  end
end
