require 'rails_helper'

describe OrderItem do
  let(:order_item) { build(:order_item) }

  describe "Order Item" do
    describe "model attributes" do
      it { expect(order_item).to respond_to(:product) }
      it { expect(order_item).to respond_to(:order) }
      it { expect(order_item).to respond_to(:monday) }
      it { expect(order_item).to respond_to(:tuesday) }
      it { expect(order_item).to respond_to(:wednesday) }
      it { expect(order_item).to respond_to(:thursday) }
      it { expect(order_item).to respond_to(:friday) }
      it { expect(order_item).to respond_to(:saturday) }
      it { expect(order_item).to respond_to(:sunday) }
    end

    describe "order" do
      it { expect(order_item).to belong_to(:order) }
      it { expect(order_item).to validate_presence_of(:client) }
    end

    describe "product" do
      it { expect(order_item).to belong_to(:product) }
      it { expect(order_item).to validate_presence_of(:product) }
    end

    describe "monday" do
      it { expect(order_item).to validate_numericality_of(:monday) }
      it { expect(order_item).to validate_presence_of(:monday) }
    end

    describe "tuesday" do
      it { expect(order_item).to validate_numericality_of(:tuesday) }
      it { expect(order_item).to validate_presence_of(:tuesday) }
    end

    describe "wednesday" do
      it { expect(order_item).to validate_numericality_of(:wednesday) }
      it { expect(order_item).to validate_presence_of(:wednesday) }
    end

    describe "thursday" do
      it { expect(order_item).to validate_numericality_of(:thursday) }
      it { expect(order_item).to validate_presence_of(:thursday) }
    end

    describe "friday" do
      it { expect(order_item).to validate_numericality_of(:friday) }
      it { expect(order_item).to validate_presence_of(:friday) }
    end

    describe "saturday" do
      it { expect(order_item).to validate_numericality_of(:saturday) }
      it { expect(order_item).to validate_presence_of(:saturday) }
    end

    describe "sunday" do
      it { expect(order_item).to validate_numericality_of(:sunday) }
      it { expect(order_item).to validate_presence_of(:sunday) }
    end
  end
end
