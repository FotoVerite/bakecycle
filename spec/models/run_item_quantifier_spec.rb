require 'rails_helper'

describe RunItemQuantifier do
  let(:bakery) { create(:bakery) }
  let(:product) { create(:product) }
  let(:production_run) { create(:production_run, bakery: bakery) }
  let!(:shipment_item) { create(:shipment_item, bakery: bakery, product: product, production_run: production_run) }
  let(:run_item) { build(:run_item, product: product, production_run: production_run) }
  let(:quantifier) { RunItemQuantifier.new(run_item) }

  describe '#order_quantity' do
    it 'sets the order quantity based on shipment_items of they exist' do
      expect(ShipmentItem).to receive(:quantities_sum).and_call_original
      expect(quantifier.order_quantity).to eq(shipment_item.product_quantity)
    end

    it 'sets the order quantity based on shipment_items of they exist' do
      allow_any_instance_of(RunItemQuantifier).to receive(:shipment_items).and_return([])
      expect(ShipmentItem).to_not receive(:quantities_sum)
      expect(quantifier.order_quantity).to eq(0)
    end
  end

  describe '#overbake_quantity' do
    it 'sets the overbake quantity based on product order quantity and product overbake' do
      allow_any_instance_of(RunItemQuantifier).to receive(:order_quantity).and_return(10)
      expect_any_instance_of(Product).to receive(:over_bake).twice.and_call_original
      overbake = product.over_bake * 10 / 100
      expect(quantifier.overbake_quantity).to eq(overbake.ceil)
    end
  end
end
