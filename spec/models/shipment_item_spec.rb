require 'rails_helper'

describe ShipmentItem do
  let(:shipment_item) { build(:shipment_item) }

  it 'has model attributes' do
    expect(shipment_item).to respond_to(:shipment)
    expect(shipment_item).to respond_to(:product_id)
    expect(shipment_item).to respond_to(:product_name)
    expect(shipment_item).to respond_to(:product_quantity)
    expect(shipment_item).to respond_to(:product_price)
    expect(shipment_item).to respond_to(:product_sku)
  end

  it 'has association' do
    expect(shipment_item).to belong_to(:shipment)
  end

  it 'has validations' do
    expect(shipment_item).to validate_presence_of(:product_id)
    expect(shipment_item).to validate_presence_of(:product_name)
    expect(shipment_item).to validate_numericality_of(:product_quantity)
    expect(shipment_item).to validate_numericality_of(:product_price)
  end

  describe '#price' do
    it 'returns the price' do
      shipment_item = build(:shipment_item, product_price: 10, product_quantity: 10)
      expect(shipment_item.price).to eq(100)
    end
  end

  describe '#product=' do
    it 'sets product data on shipment item' do
      product = build_stubbed(:product, :with_sku)
      shipment_item = ShipmentItem.new
      shipment_item.product = product

      fields = [
        :id,
        :name,
        :sku,
        :product_type,
        :total_lead_days
      ]

      fields.each do |field|
        expect(shipment_item.send("product_#{field}".to_sym)).to eq(product.send(field))
      end
    end

    it 'sets product_name from the name of the related product if that product exists' do
      product = create(:product, name: 'Product1')
      shipment_item = create(:shipment_item, product: product)
      expect(shipment_item.product_name).to eq('Product1')
    end

    it 'sets product_sku from the name of the related product if that product exists' do
      product = create(:product, :with_sku)
      shipment_item = create(:shipment_item, product: product)
      expect(shipment_item.product_sku).to eq(product.sku)
    end
  end

  describe '#production_start' do
    it 'sets production start date based on product lead time' do
      product = create(:product)
      shipment = create(:shipment)
      shipment_item = ShipmentItem.new
      shipment_item.product = product
      shipment_item.shipment = shipment
      production_start = shipment_item.shipment.date - product.total_lead_days
      shipment_item.save
      expect(shipment_item.production_start).to eq(production_start)
    end
  end

  describe '.earliest_production_date' do
    it 'returns the earliest production date for shipment items collection' do
      shipment = create(:shipment, shipment_item_count: 5)
      shipment_items = shipment.shipment_items
      earliest_shipment_item = shipment_items.order('production_start ASC').first.production_start
      expect(shipment.shipment_items.earliest_production_date).to eq(earliest_shipment_item)
    end
  end
end
