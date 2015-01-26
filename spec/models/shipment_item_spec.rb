require "rails_helper"

describe ShipmentItem do
  let(:shipment_item) { build(:shipment_item) }

  it "has model attributes" do
    expect(shipment_item).to respond_to(:shipment)
    expect(shipment_item).to respond_to(:product)
    expect(shipment_item).to respond_to(:product_name)
    expect(shipment_item).to respond_to(:product_quantity)
    expect(shipment_item).to respond_to(:price_per_item)
  end

  it "has association" do
    expect(shipment_item).to belong_to(:shipment)
    expect(shipment_item).to belong_to(:product)
  end

  it "has validations" do
    expect(shipment_item).to validate_presence_of(:product)
    expect(shipment_item).to validate_presence_of(:product_name)
    expect(shipment_item).to validate_presence_of(:product_quantity)
    expect(shipment_item).to validate_presence_of(:price_per_item)
    expect(shipment_item).to validate_numericality_of(:product_quantity)
    expect(shipment_item).to validate_numericality_of(:price_per_item)
  end

  describe "#set_product_name" do
    it "should set product_name from the name of the related product if that product exists" do
      product = create(:product, name: "Product1")
      shipment_item = create(:shipment_item, product: product)
      expect(shipment_item.product_name).to eq("Product1")
    end
  end

end
