require "rails_helper"

describe Shipment do
  let(:shipment) { build(:shipment) }

  it "has model attributes" do
    expect(shipment).to respond_to(:client)
    expect(shipment).to respond_to(:route)
    expect(shipment).to respond_to(:shipment_date)
    expect(shipment).to respond_to(:payment_due_date)
    expect(shipment).to respond_to(:shipment_items)
  end

  it "has association" do
    expect(shipment).to belong_to(:client)
    expect(shipment).to belong_to(:route)
  end

  it "has validations" do
    expect(shipment).to validate_presence_of(:route)
    expect(shipment).to validate_presence_of(:client)
    expect(shipment).to validate_presence_of(:shipment_date)
    expect(shipment).to validate_presence_of(:payment_due_date)
  end

  describe "#set_payment_due_date" do
    it "determines payment due date by reading client billing_term and appending days to shipment_date" do
      client = create(:client, billing_term: "net_30")
      shipment_with_date = create(:shipment, client: client, shipment_date: "2015-01-01")
      expect(shipment_with_date.payment_due_date).to eq(shipment_with_date.shipment_date + 30.days)
    end
  end
end
