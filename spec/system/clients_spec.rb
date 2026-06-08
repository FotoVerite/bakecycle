# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Clients", type: :system do
  let(:bakery) { create(:bakery) }
  let(:user)   { create(:user, bakery: bakery) }

  before { login_as user, scope: :user }

  describe "create" do
    it "creates a client with valid params" do
      visit new_client_path

      fill_in "Name", with: "Test Bakery Co"
      select "Net 30", from: "Billing term"
      click_button "Create"

      expect(page).to have_content("You have created Test Bakery Co")
    end

    it "shows errors with missing name" do
      visit new_client_path

      select "Net 30", from: "Billing term"
      click_button "Create"

      expect(page).to have_content("can't be blank")
    end
  end

  describe "update" do
    let!(:client) { create(:client, bakery: bakery, name: "Original Name") }

    it "updates a client name" do
      visit edit_client_path(client)

      fill_in "Name", with: "Updated Name"
      click_button "Update"

      expect(page).to have_content("You have updated Updated Name")
    end

    it "shows errors with blank name" do
      visit edit_client_path(client)

      fill_in "Name", with: ""
      click_button "Update"

      expect(page).to have_content("can't be blank")
    end
  end

  describe "destroy" do
    let!(:client) { create(:client, bakery: bakery) }

    it "deletes a client" do
      visit edit_client_path(client)

      accept_confirm { click_link "Delete" }

      expect(page).to have_content("You have deleted #{client.name}")
      expect(page).to have_current_path(clients_path)
    end
  end
end
