# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Recipes", type: :request do
  let(:bakery)  { create(:bakery) }
  let(:user)    { create(:user, bakery: bakery) }
  let!(:recipe) { create(:recipe, bakery: bakery) }

  describe "unauthenticated" do
    it "redirects to sign in" do
      get recipes_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "none permission" do
    before { sign_in create(:user, bakery: bakery, product_permission: "none") }

    it "blocks index" do
      get recipes_path
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end

    it "blocks new" do
      get new_recipe_path
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end
  end

  describe "read permission" do
    before { sign_in create(:user, bakery: bakery, product_permission: "read") }

    it "allows index" do
      get recipes_path
      expect(response).to be_successful
    end

    it "blocks edit" do
      get edit_recipe_path(recipe)
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end

    it "blocks create" do
      post recipes_path, params: { recipe: { name: "Denied" } }
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end
  end

  describe "manage permission" do
    before { sign_in user }

    it "lists recipes" do
      get recipes_path
      expect(response).to be_successful
    end

    it "shows new recipe form" do
      get new_recipe_path
      expect(response).to be_successful
      expect(response.body).to include("data-controller=\"tom-select\"")
      expect(response.body).to include("data-placeholder=\"Search ingredients\"")
    end

    it "creates a recipe with valid params" do
      params = attributes_for(:recipe).except(:bakery)
      expect {
        post recipes_path, params: { recipe: params }
      }.to change(Recipe, :count).by(1)
      expect(flash[:notice]).to match(/You have created/)
    end

    it "shows edit form" do
      create(:recipe_item, recipe: recipe, bakery: bakery)

      get edit_recipe_path(recipe)

      expect(response).to be_successful
      expect(response.body).to include("name=\"recipe[recipe_items_attributes][0][inclusionable_id_type]\"")
      expect(response.body).to_not include("name=\"recipe[recipe_items_attributes][0][0][inclusionable_id_type]\"")
    end

    it "updates a recipe" do
      patch recipe_path(recipe), params: { recipe: { name: "Sourdough" } }
      expect(recipe.reload.name).to eq("Sourdough")
      expect(flash[:notice]).to match(/You have updated/)
    end
  end

  describe "whodunnit column" do
    before { sign_in user }

    it "renders updated_at list without crashing when a recipe has no versions" do
      PaperTrail::Version.where(item: recipe).delete_all
      expect(recipe.reload.versions).to be_empty

      get updated_at_recipes_path

      expect(response).to be_successful
    end

    it "renders created_at list without crashing when a recipe has no versions" do
      PaperTrail::Version.where(item: recipe).delete_all
      expect(recipe.reload.versions).to be_empty

      get created_at_recipes_path

      expect(response).to be_successful
    end

    it "shows 'Unknown user' when the editor was deleted" do
      editor = create(:user, bakery: bakery)
      sign_in editor
      patch recipe_path(recipe), params: { recipe: { name: "Sourdough" } }
      editor.destroy

      sign_in user
      get updated_at_recipes_path

      expect(response).to be_successful
      expect(response.body).to include("Unknown user")
    end
  end

  describe "data scoping" do
    before { sign_in user }

    it "redirects to index for another bakery's recipe" do
      other = create(:recipe, bakery: create(:bakery))
      get edit_recipe_path(other)
      expect(response).to redirect_to(recipes_path)
      expect(flash[:alert]).to eq("That record no longer exists.")
    end
  end
end
