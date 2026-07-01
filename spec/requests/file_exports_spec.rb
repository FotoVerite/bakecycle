# frozen_string_literal: true

require "rails_helper"

RSpec.describe "FileExports", type: :request do
  let(:bakery) { create(:bakery) }
  let(:user)   { create(:user, bakery: bakery) }

  describe "GET /file_exports" do
    it "redirects to sign in when unauthenticated" do
      get file_exports_path
      expect(response).to redirect_to(new_user_session_path)
    end

    context "when authenticated" do
      before { sign_in user }

      it "returns 200" do
        get file_exports_path
        expect(response).to have_http_status(:ok)
      end

      it "lists only the current bakery's exports" do
        mine = create(:file_export, :with_file, bakery: bakery)
        other = create(:file_export, :with_file, bakery: create(:bakery))

        get file_exports_path

        expect(response.body).to include("file_export_#{mine.id}")
        expect(response.body).not_to include("file_export_#{other.id}")
      end

      it "shows at most the 10 most recently created exports" do
        exports = Array.new(11) { |i| create(:file_export, :with_file, bakery: bakery, created_at: i.days.ago) }
        oldest = exports.min_by(&:created_at)

        get file_exports_path

        expect(response.body).not_to include("file_export_#{oldest.id}")
      end
    end
  end
end
