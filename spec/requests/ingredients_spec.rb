# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Ingredients", type: :request do
  let(:bakery)      { create(:bakery) }
  let(:user)        { create(:user, bakery: bakery) }
  let!(:ingredient) { create(:ingredient, bakery: bakery) }

  describe "unauthenticated" do
    it "redirects to sign in" do
      get ingredients_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "none permission" do
    before { sign_in create(:user, bakery: bakery, product_permission: "none") }

    it "blocks index" do
      get ingredients_path
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end

    it "blocks new" do
      get new_ingredient_path
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end
  end

  describe "read permission" do
    before { sign_in create(:user, bakery: bakery, product_permission: "read") }

    it "allows index" do
      get ingredients_path
      expect(response).to be_successful
    end

    it "blocks create" do
      post ingredients_path, params: { ingredient: { name: "Denied" } }
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end

    it "blocks edit" do
      get edit_ingredient_path(ingredient)
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end
  end

  describe "manage permission" do
    before { sign_in user }

    it "lists ingredients" do
      get ingredients_path
      expect(response).to be_successful
    end

    it "shows new ingredient form" do
      get new_ingredient_path
      expect(response).to be_successful
    end

    it "creates an ingredient" do
      params = attributes_for(:ingredient).except(:bakery)
      expect {
        post ingredients_path, params: { ingredient: params }
      }.to change(Ingredient, :count).by(1)
      expect(flash[:notice]).to match(/You have created/)
    end

    it "shows edit form" do
      get edit_ingredient_path(ingredient)
      expect(response).to be_successful
    end

    it "updates an ingredient" do
      patch ingredient_path(ingredient), params: { ingredient: { name: "Oat Flour" } }
      expect(ingredient.reload.name).to eq("Oat Flour")
      expect(flash[:notice]).to match(/You have updated/)
    end
  end

  describe "data scoping" do
    before { sign_in user }

    it "redirects to index for another bakery's ingredient" do
      other = create(:ingredient, bakery: create(:bakery))
      get edit_ingredient_path(other)
      expect(response).to redirect_to(ingredients_path)
      expect(flash[:alert]).to eq("That record no longer exists.")
    end
  end
end
