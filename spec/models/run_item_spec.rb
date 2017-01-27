# == Schema Information
#
# Table name: run_items
#
#  id                :integer          not null, primary key
#  production_run_id :integer          not null
#  product_id        :integer          not null
#  total_quantity    :integer
#  order_quantity    :integer
#  overbake_quantity :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require "rails_helper"

describe RunItem do
  describe ".order_by_product_name" do
    it "sorts by product name" do
      create_list(:run_item, 5)
      ordered_product_names = RunItem.all.sort_by { |run_item| run_item.product.name }
      expect(RunItem.order_by_product_name).to eq(ordered_product_names)
    end
  end

  describe ".order_by_product_type_and_name" do
    it "sorts by product name" do
      create_list(:run_item, 2, product_product_type: "vienoisserie")
      create_list(:run_item, 2, product_product_type: "bread")
      create_list(:run_item, 2, product_product_type: "pot_pie")

      ordered_by_product_type_and_names = RunItem.all.sort_by do |run_item|
        [run_item.product.product_type, run_item.product.name]
      end

      expect(RunItem.order_by_product_type_and_name).to eq(ordered_by_product_type_and_names)
    end
  end

  describe "#initialize_quantities" do
    it "calls RunItemQuantifier" do
      expect_any_instance_of(RunItemQuantifier).to receive(:set)
      build(:run_item, shipment_items: [])
    end
  end

  describe "#update" do
    let(:run_item) { build(:run_item, overbake_quantity: 10, total_quantity: 10, order_quantity: 0) }

    it "changed the total quantity before validation" do
      run_item.overbake_quantity = 30
      run_item.valid?
      expect(run_item.overbake_quantity).to eq(30)
      expect(run_item.total_quantity).to eq(30)
    end
  end

  describe "uniqueness" do
    it "enforces uniqueness" do
      expect(create(:run_item)).to validate_uniqueness_of(:product)
        .scoped_to(:production_run_id)
        .with_message("Cannot add the same product more than once")
    end
  end
end
