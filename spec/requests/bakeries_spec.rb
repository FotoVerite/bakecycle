# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Bakeries", type: :request do
  let(:bakery) { create(:bakery) }
  let(:user)   { create(:user, bakery: bakery) }
  let(:admin)  { create(:user, :as_admin, bakery: bakery) }

  describe "admin-only index" do
    it "allows admin to list all bakeries" do
      sign_in admin
      get bakeries_path
      expect(response).to be_successful
    end

    it "blocks non-admin from bakeries index" do
      sign_in user
      get bakeries_path
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end
  end

  # mybakery is the bakery settings page for the current user's bakery.
  # It renders the edit form and authorizes via edit?, which requires manage permission.
  describe "own bakery settings (mybakery)" do
    it "allows manage permission to view own bakery settings" do
      sign_in create(:user, bakery: bakery, bakery_permission: "manage")
      get my_bakeries_path
      expect(response).to be_successful
    end

    it "blocks read permission (mybakery renders edit form, requires manage)" do
      sign_in create(:user, bakery: bakery, bakery_permission: "read")
      get my_bakeries_path
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end

    it "redirects when none permission (scope returns empty)" do
      sign_in create(:user, bakery: bakery, bakery_permission: "none")
      get my_bakeries_path
      expect(response).to redirect_to(bakeries_path)
      expect(flash[:alert]).to eq("That record no longer exists.")
    end
  end

  describe "admin bakery CRUD" do
    before { sign_in admin }

    it "shows new bakery form" do
      get new_bakery_path
      expect(response).to be_successful
    end

    it "shows edit form for any bakery" do
      other = create(:bakery)
      get edit_bakery_path(other)
      expect(response).to be_successful
    end

    it "updates any bakery" do
      other = create(:bakery)
      patch bakery_path(other), params: { bakery: { name: "Updated Name" } }
      expect(other.reload.name).to eq("Updated Name")
    end

    it "updates kickoff time from a native time input value" do
      other = create(:bakery)
      patch bakery_path(other), params: { bakery: { kickoff_time: "17:30" } }
      expect(other.reload.kickoff_time.strftime("%H:%M")).to eq("17:30")
    end
  end
end
