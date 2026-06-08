# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Routes", type: :request do
  let(:bakery) { create(:bakery) }
  let(:user)   { create(:user, bakery: bakery) }
  let!(:route) { create(:route, bakery: bakery) }

  describe "unauthenticated" do
    it "redirects to sign in" do
      get routes_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "manage permission" do
    before { sign_in user }

    it "lists routes" do
      get routes_path
      expect(response).to be_successful
    end

    it "shows new route form" do
      get new_route_path
      expect(response).to be_successful
    end

    it "creates a route" do
      expect {
        post routes_path, params: { route: { name: "East Side Run", active: true, departure_time: "6:00 AM" } }
      }.to change(Route, :count).by(1)
      expect(flash[:notice]).to match(/You have created/)
    end

    it "creates a route from a native time input value" do
      expect {
        post routes_path, params: { route: { name: "Early Run", active: true, departure_time: "06:00" } }
      }.to change(Route, :count).by(1)
      expect(Route.last.departure_time.strftime("%H:%M")).to eq("06:00")
    end

    it "shows edit form" do
      get edit_route_path(route)
      expect(response).to be_successful
    end

    it "updates a route" do
      patch route_path(route), params: { route: { name: "West Side Run" } }
      expect(route.reload.name).to eq("West Side Run")
      expect(flash[:notice]).to match(/You have updated/)
    end

    it "deletes a route when another exists" do
      other = create(:route, bakery: bakery)
      delete route_path(other)
      expect(flash[:notice]).to match(/You have deleted/)
    end

    it "blocks deleting the last remaining route" do
      delete route_path(route)
      expect(flash[:error]).to match(/Cannot delete last remaining route/)
      expect(Route.exists?(route.id)).to be true
    end
  end

  describe "data scoping" do
    before { sign_in user }

    it "redirects to index for another bakery's route" do
      other = create(:route, bakery: create(:bakery))
      get edit_route_path(other)
      expect(response).to redirect_to(routes_path)
      expect(flash[:alert]).to eq("That record no longer exists.")
    end
  end
end
