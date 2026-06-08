# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Report date filters", type: :request do
  let(:bakery) { create(:bakery) }
  let(:user)   { create(:user, bakery: bakery) }
  let(:route)  { create(:route, bakery: bakery) }

  let(:matched_client)   { create(:client, bakery: bakery, name: "Matched Cafe") }
  let(:unmatched_client) { create(:client, bakery: bakery, name: "Other Cafe") }

  before do
    sign_in user
    create(:shipment, bakery: bakery, client: matched_client, route: route, date: Date.new(2026, 6, 3))
    create(:shipment, bakery: bakery, client: unmatched_client, route: route, date: Date.new(2026, 6, 4))
  end

  it "filters packing slips by the selected date" do
    get packing_slips_path(date: "2026-06-03")

    expect(response).to be_successful
    expect(response.body).to include("Wednesday Jun.  3, 2026")
    expect(response.body).to include("Matched Cafe")
    expect(response.body).to_not include("Other Cafe")
  end

  it "accepts legacy nested search date params" do
    get packing_slips_path(search: { date: "2026-06-03" })

    expect(response).to be_successful
    expect(response.body).to include("Wednesday Jun.  3, 2026")
    expect(response.body).to include("Matched Cafe")
    expect(response.body).to_not include("Other Cafe")
  end

  it "filters delivery lists by the selected date" do
    get delivery_lists_path(date: "2026-06-03")

    expect(response).to be_successful
    expect(response.body).to include("Wednesday Jun.  3, 2026")
    expect(response.body).to include("Matched Cafe")
    expect(response.body).to_not include("Other Cafe")
  end

  it "filters daily totals by the selected date" do
    get daily_totals_path(date: "2026-06-03")

    expect(response).to be_successful
    expect(response.body).to include("Wednesday Jun.  3, 2026")
    expect(response.body).to include(route.name)
  end
end
