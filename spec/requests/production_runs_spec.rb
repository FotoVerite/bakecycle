require "rails_helper"

RSpec.describe "Production runs", type: :request do
  let(:bakery)          { create(:bakery) }
  let(:user)            { create(:user, bakery: bakery) }
  let!(:production_run) { create(:production_run, bakery: bakery) }

  describe "unauthenticated" do
    it "redirects to sign in" do
      get production_runs_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "none production permission" do
    before { sign_in create(:user, bakery: bakery, production_permission: "none") }

    it "blocks production runs index" do
      get production_runs_path
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end

    it "blocks print recipes page" do
      get print_recipes_path
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end
  end

  describe "read permission" do
    before { sign_in create(:user, bakery: bakery, production_permission: "read") }

    it "allows production runs index" do
      get production_runs_path
      expect(response).to be_successful
    end

    it "allows print recipes page" do
      get print_recipes_path
      expect(response).to be_successful
    end

    it "blocks edit" do
      get edit_production_run_path(production_run)
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end
  end

  describe "manage permission" do
    before { sign_in user }

    it "lists production runs" do
      get production_runs_path
      expect(response).to be_successful
    end

    it "shows the print recipes page" do
      get print_recipes_path
      expect(response).to be_successful
    end

    it "shows edit form" do
      get edit_production_run_path(production_run)
      expect(response).to be_successful
    end

    it "updates run items on a production run" do
      patch production_run_path(production_run), params: { production_run: { run_items_attributes: [] } }
      expect(response).to be_redirect
    end
  end
end
