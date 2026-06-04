require "rails_helper"

RSpec.describe "Vendors", type: :request do
  let(:bakery) { create(:bakery) }
  let(:user)   { create(:user, bakery: bakery) }
  let!(:vendor) { create(:vendor, bakery: bakery) }

  describe "unauthenticated" do
    it "redirects to sign in" do
      get vendors_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "manage permission" do
    before { sign_in user }

    it "lists vendors" do
      get vendors_path
      expect(response).to be_successful
    end

    it "shows new vendor form" do
      get new_vendor_path
      expect(response).to be_successful
    end

    it "creates a vendor" do
      expect {
        post vendors_path, params: { vendor: { name: "Flour Co", contact: "Jane", email: "jane@flour.co", phone: "555-1234" } }
      }.to change(Vendor, :count).by(1)
      expect(flash[:notice]).to match(/You have created/)
    end

    it "shows edit form" do
      get edit_vendor_path(vendor)
      expect(response).to be_successful
    end

    it "updates a vendor" do
      patch vendor_path(vendor), params: { vendor: { name: "New Flour Co" } }
      expect(vendor.reload.name).to eq("New Flour Co")
      expect(flash[:notice]).to match(/You have updated/)
    end

    it "deletes a vendor" do
      delete vendor_path(vendor)
      expect(flash[:notice]).to match(/You have deleted/)
    end
  end

  describe "data scoping" do
    before { sign_in user }

    it "raises RecordNotFound for another bakery's vendor" do
      other = create(:vendor, bakery: create(:bakery))
      expect { get edit_vendor_path(other) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
