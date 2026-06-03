require "rails_helper"

describe OrderFormSerializer do
  let(:bakery) { create(:bakery) }
  let(:user) { create(:user, bakery: bakery) }
  let(:order) { create(:order, bakery: bakery, order_item_count: 0) }
  let(:form) { OrderForm.new(order: order, user: user) }

  subject(:hash) { form.serializable_hash }

  it "exposes order as a top-level string key" do
    expect(hash).to have_key("order")
    expect(hash["order"]).to be_a(Hash)
  end

  it "includes the order id" do
    expect(hash["order"]).to include(id: order.id)
  end

  it "includes kickoff_time injected by OrderForm" do
    expect(hash["order"]).to have_key("kickoff_time")
    expect(hash["order"]["kickoff_time"]).to eq(bakery.kickoff_time)
  end

  # React's OrderFormProvider expects camelCase prop names
  it "exposes availableClients as a camelCase array" do
    expect(hash).to have_key("availableClients")
    expect(hash["availableClients"]).to be_an(Array)
  end

  it "exposes availableRoutes as a camelCase array" do
    expect(hash).to have_key("availableRoutes")
    expect(hash["availableRoutes"]).to be_an(Array)
  end

  it "exposes availableProducts as a camelCase array" do
    expect(hash).to have_key("availableProducts")
    expect(hash["availableProducts"]).to be_an(Array)
  end
end
