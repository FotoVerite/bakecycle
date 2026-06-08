# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Routes", type: :system do
  let(:bakery) { create(:bakery) }
  let(:user)   { create(:user, bakery: bakery) }

  before { login_as user, scope: :user }

  describe "create" do
    it "creates a route with valid params" do
      visit new_route_path

      fill_in "Name", with: "Morning Route"
      page.execute_script("document.querySelector('input.js-timepicker').value = '06:00'")
      click_button "Create"

      expect(page).to have_content("You have created Morning Route")
    end

    it "shows errors with missing name" do
      visit new_route_path

      page.execute_script("document.querySelector('input.js-timepicker').value = '06:00'")
      click_button "Create"

      expect(page).to have_content("can't be blank")
    end
  end

  describe "update" do
    let!(:route) { create(:route, bakery: bakery, name: "Old Route") }

    it "updates a route name" do
      visit edit_route_path(route)

      fill_in "Name", with: "New Route"
      click_button "Update"

      expect(page).to have_content("You have updated New Route")
    end
  end

  describe "destroy" do
    let!(:route)  { create(:route, bakery: bakery) }
    let!(:route2) { create(:route, bakery: bakery) }

    it "deletes a route" do
      visit edit_route_path(route)

      accept_confirm { click_link "Delete" }

      expect(page).to have_content("You have deleted #{route.name}")
      expect(page).to have_current_path(routes_path)
    end
  end
end
