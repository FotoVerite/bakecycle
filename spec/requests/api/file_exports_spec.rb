require "rails_helper"

RSpec.describe "Api::FileExports", type: :request do
  let(:bakery)      { create(:bakery) }
  let(:user)        { create(:user, bakery: bakery) }
  let(:file_export) { create(:file_export, bakery: bakery) }

  describe "GET /api/file_exports/:id" do
    it "redirects to sign in when unauthenticated" do
      get api_file_export_path(file_export)
      expect(response).to redirect_to(new_user_session_path)
    end

    context "when authenticated" do
      before { sign_in user }

      it "returns 200" do
        get api_file_export_path(file_export)
        expect(response).to have_http_status(:ok)
      end

      it "returns JSON with ready false when file is not yet generated" do
        get api_file_export_path(file_export)
        data = JSON.parse(response.body)["fileExport"]
        expect(data["ready?"]).to be false
        expect(data["links"]["self"]).to be_present
        expect(data["links"]["file"]).to be_nil
      end

      it "returns JSON with ready true and a file URL when generated" do
        file_export_with_file = create(:file_export, :with_file, bakery: bakery)
        get api_file_export_path(file_export_with_file)
        data = JSON.parse(response.body)["fileExport"]
        expect(data["ready?"]).to be true
        expect(data["links"]["file"]).to be_present
      end

      it "raises RecordNotFound for another bakery's export" do
        other = create(:file_export, bakery: create(:bakery))
        expect { get api_file_export_path(other) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
