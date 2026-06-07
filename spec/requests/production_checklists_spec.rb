require "rails_helper"

RSpec.describe "Production checklist", type: :request do
  let(:bakery) { create(:bakery) }
  let(:user)   { create(:user, bakery: bakery) }

  describe "unauthenticated" do
    it "redirects to sign in" do
      get production_checklist_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "authenticated" do
    before { sign_in user }

    it "shows the production checklist" do
      get production_checklist_path
      expect(response).to be_successful
    end
  end
end
