# frozen_string_literal: true

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

    it "shows an all-clear empty state when there is nothing actionable" do
      get production_checklist_path
      expect(response.body).to include("All clear")
    end

    it "hides the empty state when there are missing invoices" do
      Timecop.freeze(Time.zone.now.change(hour: 15)) do
        create(:order, bakery: bakery, start_date: Time.zone.today - 1.week, force_total_lead_days: 1,
                       order_item_count: 1)

        get production_checklist_path

        expect(response.body).to_not include("All clear")
        expect(response.body).to include("missing invoices")
      end
    end
  end
end
