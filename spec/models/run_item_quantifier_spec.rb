require 'rails_helper'

describe RunItemQuantifier do
  let(:bakery) { create(:bakery) }
  let(:product) { create(:product) }
  let(:production_run) { create(:production_run, bakery: bakery) }
  let!(:shipment_item) { create(:shipment_item, bakery: bakery, product: product, production_run: production_run) }
  let(:run_item) { build(:run_item, product: product, production_run: production_run) }
  let(:quantifier) { RunItemQuantifier.new(run_item) }

  describe '#order_quantity' do
    it 'sets the order quantity based on shipment_items' do
      expect(quantifier.order_quantity).to eq(shipment_item.product_quantity)
    end
  end

  describe '#overbake_quantity' do
    it 'sets the overbake quantity based on product order quantity and product overbake' do
      allow_any_instance_of(RunItemQuantifier).to receive(:order_quantity).and_return(10)
      allow(ShipmentItem).to receive(:quantities_sum).and_return(10)
      overbake = product.over_bake * 10 / 100
      expect(quantifier.overbake_quantity).to eq(overbake.ceil)
    end
  end

  describe '#total_quantity' do
    it 'sets the order quantity based on order quantity and overbake quantity' do
      allow_any_instance_of(RunItemQuantifier).to receive(:order_quantity).and_return(10)
      allow_any_instance_of(Product).to receive(:over_bake).and_return(50)
      expect(quantifier.total_quantity).to eq(15)
    end
  end
end
