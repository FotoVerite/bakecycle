# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Recipes", type: :system do
  let(:bakery) { create(:bakery) }
  let(:user)   { create(:user, bakery: bakery) }

  before { login_as user, scope: :user }

  describe "create" do
    it "creates a recipe with valid params" do
      visit new_recipe_path

      fill_in "Name", with: "Sourdough Base"
      select "Dough", from: "Recipe type"
      fill_in "Lead Days", with: "2"
      click_button "Create Recipe"

      expect(page).to have_content("You have created Sourdough Base")
    end

    it "shows errors with missing name" do
      visit new_recipe_path

      select "Dough", from: "Recipe type"
      fill_in "Lead Days", with: "1"
      click_button "Create Recipe"

      expect(page).to have_content("can't be blank")
    end
  end

  describe "update" do
    let!(:recipe) { create(:recipe, bakery: bakery, name: "Old Recipe") }

    it "updates a recipe name" do
      visit edit_recipe_path(recipe)

      fill_in "Name", with: "Updated Recipe"
      click_button "Save Changes"

      expect(page).to have_content("You have updated Updated Recipe")
    end
  end

  describe "destroy" do
    let!(:recipe) { create(:recipe, bakery: bakery) }

    it "deletes a recipe" do
      visit edit_recipe_path(recipe)

      accept_confirm { click_link "Delete" }

      expect(page).to have_content("You have deleted #{recipe.name}")
      expect(page).to have_current_path(recipes_path)
    end
  end
end
