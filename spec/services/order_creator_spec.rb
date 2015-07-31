require "rails_helper"

describe OrderCreator do
  let(:bakery) { create(:bakery) }
  let(:client) { create(:client) }
  let(:route) { create(:route) }
  let(:old_order) { create(:order, start_date: Time.zone.now - 1.day, bakery: bakery, client: client, route: route) }
  let(:new_order) { build(:order, start_date: Time.zone.now, bakery: bakery, client: client, route: route) }

  describe "#run" do
    it "overrides an order and saves new order if there is an overridable order" do
      old_order
      allow_any_instance_of(OrderCreator).to receive(:overlap_errors_only?)
      allow_any_instance_of(Order).to receive(:overridable_order).and_return(old_order)
      expect_any_instance_of(Order).to receive(:update).and_call_original
      creator = OrderCreator.new(new_order, true)
      expect(creator.run).to eq(true)
    end

    it "adds an error if it could not override an order and does not save new order" do
      old_order
      allow_any_instance_of(OrderCreator).to receive(:overlap_errors_only?).and_return(true)
      allow_any_instance_of(Order).to receive(:overridable_order).and_return(old_order)
      allow_any_instance_of(Order).to receive(:save).and_return(false)
      creator = OrderCreator.new(new_order, true)
      expect(creator.run).to eq(false)
      message = "Could not override overlapping order, please update it manually."
      expect(new_order.errors.full_messages).to include(message)
    end

    it "saves an order if there is not an overridable order" do
      expect_any_instance_of(Order).not_to receive(:update).and_call_original
      creator = OrderCreator.new(new_order)
      expect(creator.run).to eq(true)
    end
  end
end
