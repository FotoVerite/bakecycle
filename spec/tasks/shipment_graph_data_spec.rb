# frozen_string_literal: true

require "rails_helper"

RSpec.describe "shipment_graph_data", type: :task do
  it "generates shipment graph data" do
    expect(ShipmentGraphDataService).to receive(:generate)

    rake_task("shipment_graph_data:generate").invoke
  end

  it "digests shipment graph data for the last week" do
    expect(ShipmentGraphDataService).to receive(:digest_last_week)

    rake_task("shipment_graph_data:digest_last_week").invoke
  end
end
