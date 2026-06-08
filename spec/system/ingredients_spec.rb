# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Ingredients", type: :system do
  let(:bakery) { create(:bakery) }
  let(:user)   { create(:user, bakery: bakery) }

  before { login_as user, scope: :user }

  describe "create" do
    it "creates an ingredient with valid params" do
      visit new_ingredient_path

      fill_in "Name", with: "Bread Flour"
      click_button "Create"

      expect(page).to have_content("You have created Bread Flour")
    end

    it "shows errors with missing name" do
      visit new_ingredient_path

      click_button "Create"

      expect(page).to have_content("can't be blank")
    end
  end

  describe "update" do
    let!(:ingredient) { create(:ingredient, bakery: bakery, name: "Old Flour") }

    it "updates an ingredient name" do
      visit edit_ingredient_path(ingredient)

      fill_in "Name", with: "New Flour"
      click_button "Update"

      expect(page).to have_content("You have updated New Flour")
    end
  end

  describe "destroy" do
    let!(:ingredient) { create(:ingredient, bakery: bakery) }

    it "deletes an ingredient" do
      visit edit_ingredient_path(ingredient)

      accept_confirm { click_link "Delete" }

      expect(page).to have_content("You have deleted #{ingredient.name}")
      expect(page).to have_current_path(ingredients_path)
    end
  end
end
