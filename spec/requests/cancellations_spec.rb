# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Cancellations", type: :request do
  let(:bakery)  { create(:bakery) }
  let(:user)    { create(:user, bakery: bakery) }
  let(:client)  { create(:client, bakery: bakery) }
  let(:date)    { Date.tomorrow.to_s }

  describe "unauthenticated" do
    it "redirects to sign in on GET new" do
      get new_cancellation_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects to sign in on POST create" do
      post cancellations_path, params: { date: date, step: "preview", client_ids: [client.id] }
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "authenticated without client manage permission" do
    let(:user) { create(:user, bakery: bakery, client_permission: "read") }

    before { sign_in user }

    it "denies GET new" do
      get new_cancellation_path
      expect(response).to redirect_to(dashboard_path)
    end

    it "denies POST create" do
      post cancellations_path, params: { date: date, step: "preview", client_ids: [client.id] }
      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "authenticated" do
    before { sign_in user }

    describe "GET new" do
      it "renders successfully" do
        get new_cancellation_path
        expect(response).to be_successful
      end

      it "defaults to tomorrow's date" do
        get new_cancellation_path
        expect(response.body).to include(Date.tomorrow.strftime("%Y-%m-%d"))
      end

      it "accepts a date param" do
        get new_cancellation_path, params: { date: "2025-06-30" }
        expect(response.body).to include("2025-06-30")
      end
    end

    describe "POST create — no clients selected" do
      it "re-renders with unprocessable_entity when client_ids is empty" do
        post cancellations_path, params: { date: date, step: "preview", client_ids: [] }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "POST create step=preview" do
      it "renders the confirmation step" do
        post cancellations_path, params: { date: date, step: "preview", client_ids: [client.id] }
        expect(response).to be_successful
      end

      it "does not modify any data" do
        expect {
          post cancellations_path, params: { date: date, step: "preview", client_ids: [client.id] }
        }.not_to(change { Order.count })
      end
    end

    describe "POST create step=confirm" do
      it "renders the results step" do
        post cancellations_path, params: { date: date, step: "confirm", client_ids: [client.id] }
        expect(response).to be_successful
      end

      it "creates a zero-quantity temp order for an eligible client" do
        route  = create(:route, bakery: bakery)
        order  = create(:order, bakery: bakery, client: client, route: route,
                                order_type: "standing", start_date: Date.tomorrow - 1.week)
        create(:order_item, order: order, bakery: bakery)
        order.reload

        expect {
          post cancellations_path, params: {
            date: date, step: "confirm", client_ids: [client.id]
          }
        }.to change { Order.where(order_type: "temporary", client: client).count }.by(1)

        temp = Order.temporary(date).where(client: client, bakery: bakery).first
        expect(temp.order_items.size).to eq(1)
        expect(temp.order_items.first.quantity(Date.parse(date))).to eq(0)
      end
    end
  end
end
