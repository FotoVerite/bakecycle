# frozen_string_literal: true

require "rails_helper"

describe OrderGenerator do
  let(:bakery) { create(:bakery) }
  let(:client) { create(:client, bakery: bakery, name: "Jane's Café & Market") }
  let(:order) { create(:order, bakery: bakery, client: client) }

  it "prepends the client name to the filename" do
    expect(described_class.new(order).filename).to eq("Jane-s-Cafe-Market-Order-#{order.id}.pdf")
  end
end
