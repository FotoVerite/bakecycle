# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication", type: :request do
  describe "unauthenticated access" do
    it "does not show bakery context on the sign in page" do
      get new_user_session_path

      expect(response.body).not_to include("No bakery selected")
      expect(response.body).not_to include("bakery-context")
    end

    it "redirects to sign in from any protected page" do
      get clients_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects to sign in from dashboard" do
      get dashboard_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "POST /users/sign_in" do
    let(:bakery) { create(:bakery) }
    let!(:user) { create(:user, bakery: bakery, email: "test@example.com", password: "foobarbaz") }

    it "signs in with valid credentials and redirects to dashboard" do
      post user_session_path, params: { user: { email: "test@example.com", password: "foobarbaz" } }
      expect(response).to redirect_to(dashboard_path)
    end

    it "rejects invalid credentials" do
      post user_session_path, params: { user: { email: "test@example.com", password: "wrongpass" } }
      expect(response).not_to redirect_to(dashboard_path)
    end
  end
end
