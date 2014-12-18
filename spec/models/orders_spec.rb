require "rails_helper"

describe Order do
  let(:order) { build(:order) }

  describe "model attributes" do
    it { expect(order).to respond_to(:client) }
    it { expect(order).to respond_to(:route) }
    it { expect(order).to respond_to(:start_date) }
    it { expect(order).to respond_to(:end_date) }
    it { expect(order).to respond_to(:note) }
  end

  describe "validations" do

    describe "client" do
      it { expect(order).to belong_to(:client) }
      it { expect(order).to validate_presence_of(:client) }
    end

    describe "route" do
      it { expect(order).to belong_to(:route) }
      it { expect(order).to validate_presence_of(:route) }
    end

    describe "effective date" do
      it { expect(order).to validate_presence_of(:start_date) }
    end
  end
end
