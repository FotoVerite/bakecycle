require "rails_helper"

describe BatchRecipesCsv do
  describe ".to_csv" do
    let(:mock_projection) { MockProjection.new }

    it "Returns a csv based on a projection" do
      csv = BatchRecipesCsv.new(mock_projection).to_csv
      expect(csv).to eq mock_csv
    end
  end
end

def mock_csv
  CSV.generate do |csv|
    csv << ["Product", "Total Quantity", "Order Quantity", "Over Bake %", "Over Bake Quantity"]
    5.times { csv << ["Biscuit", 5, 5, 10, 10] }
  end
end

class MockProjection
  attr_reader :products_info

  def initialize
    @products_info = 5.times.map { MockProductInfo.new }
  end
end

class MockProductInfo
  attr_reader :product_name, :total_quantity, :order_quantity, :product_over_bake, :overbake_quantity

  def initialize
    @product_name = "Biscuit"
    @total_quantity = 5
    @order_quantity = 5
    @product_over_bake = 10
    @overbake_quantity = 10
  end
end
