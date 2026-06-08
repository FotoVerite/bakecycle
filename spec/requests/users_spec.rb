# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users", type: :request do
  let(:bakery) { create(:bakery) }
  let(:user)   { create(:user, bakery: bakery) }
  let!(:other_user) { create(:user, bakery: bakery) }

  describe "unauthenticated" do
    it "redirects to sign in" do
      get users_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "manage permission" do
    before { sign_in user }

    it "lists users" do
      get users_path
      expect(response).to be_successful
    end

    it "shows new user form" do
      get new_user_path
      expect(response).to be_successful
    end

    it "shows edit form" do
      get edit_user_path(other_user)
      expect(response).to be_successful
    end

    it "shows my account" do
      get my_users_path
      expect(response).to be_successful
    end

    it "updates a user's name" do
      patch user_path(other_user), params: { user: { name: "Jane Smith", password: "", password_confirmation: "" } }
      expect(other_user.reload.name).to eq("Jane Smith")
      expect(flash[:notice]).to match(/You have updated/)
    end

    it "deletes a user" do
      delete user_path(other_user)
      expect(flash[:notice]).to match(/You have deleted/)
      expect(User.exists?(other_user.id)).to be false
    end
  end

  describe "data scoping" do
    before { sign_in user }

    it "redirects to index for another bakery's user" do
      other = create(:user, bakery: create(:bakery))
      get edit_user_path(other)
      expect(response).to redirect_to(users_path)
      expect(flash[:alert]).to eq("That record no longer exists.")
    end
  end
end
