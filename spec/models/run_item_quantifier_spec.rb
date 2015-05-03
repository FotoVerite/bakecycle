require 'rails_helper'

describe RunItemQuantifier do
  let(:bakery) { build_stubbed(:bakery) }
  let(:product) { build_stubbed(:product, bakery: bakery) }
  let(:shipment_item) { build_stubbed(:shipment_item, bakery: bakery, product: product) }
  let(:run_item) { RunItem.new(product: product) }
  let(:quantifier) { RunItemQuantifier.new(run_item, [shipment_item]) }

  it 'requires shipment items to have the same product as the run_item' do
    other_shipment_items = [build_stubbed(:shipment_item)]
    expect {
      RunItemQuantifier.new(run_item, other_shipment_items)
    }.to raise_error(ArgumentError)
  end

  context 'order_quantity' do
    it 'sets the order quantity based on shipment_items' do
      shipment_item.product_quantity = 4
      quantifier.set
      expect(run_item.order_quantity).to eq(shipment_item.product_quantity)
    end

    it 'sets the order quantity based on shipment_items when there are none' do
      RunItemQuantifier.new(run_item, []).set
      expect(run_item.order_quantity).to eq(0)
    end
  end

  describe '#overbake_quantity' do
    it 'sets the overbake quantity based on product order quantity and product overbake' do
      shipment_item.product_quantity = 10
      overbake = product.over_bake * 10 / 100
      quantifier.set
      expect(run_item.overbake_quantity).to eq(overbake.ceil)
    end
  end
end
