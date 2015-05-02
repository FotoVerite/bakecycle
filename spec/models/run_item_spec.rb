require 'rails_helper'

describe RunItem do
  describe '#initialize_quantities' do
    it 'calls RunItemQuantifier' do
      expect_any_instance_of(RunItemQuantifier).to receive(:set)
      build(:run_item, shipment_items: [])
    end
  end

  describe '#update' do
    let(:run_item) { build(:run_item, overbake_quantity: 10, total_quantity: 10, order_quantity: 0) }

    it 'changed the total quantity before validation' do
      run_item.overbake_quantity = 30
      run_item.valid?
      expect(run_item.overbake_quantity).to eq(30)
      expect(run_item.total_quantity).to eq(30)
    end
  end
end
