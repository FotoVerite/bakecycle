# frozen_string_literal: true

require "rails_helper"

RSpec.describe "product_graph_data", type: :task do
  it "digests product graph data for the last week" do
    expect(ProductGraphDataService).to receive(:digest_last_week)

    rake_task("product_graph_data:digest_last_week").invoke
  end
end
