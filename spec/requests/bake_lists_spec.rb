# frozen_string_literal: true

require "rails_helper"

RSpec.describe "BakeLists", type: :request do
  let(:bakery) { create(:bakery) }
  let(:user) { create(:user, bakery: bakery) }

  describe "unauthenticated" do
    it "redirects to sign in" do
      get bake_lists_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "signed in" do
    before { sign_in user }

    it "renders the index page" do
      get bake_lists_path
      expect(response).to be_successful
      expect(response.body).to include("Bake List")
    end

    it "starts the bake list export" do
      file_export = create(:file_export, bakery: bakery)
      allow(ExporterJob).to receive(:create).and_return(file_export)

      get print_bake_lists_path(date: "2026-06-03")

      expect(ExporterJob).to have_received(:create).with(
        user, bakery, have_attributes(filename: "Bake-List-2026-06-03.xlsx")
      )
      expect(response).to redirect_to(file_export)
    end
  end
end
