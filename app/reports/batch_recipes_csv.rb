class BatchRecipesCsv
  attr_reader :projection

  def initialize(projection)
    @projection = projection
  end

  def to_csv
    CSV.generate do |csv|
      csv << ["Product", "Total Quantity", "Order Quantity",
              "Over Bake %", "Over Bake Quantity"]
      @projection.products_info.each do |product|
        csv << [
          product.product_name,
          product.total_quantity,
          product.order_quantity,
          product.product_over_bake,
          product.overbake_quantity
        ]
      end
    end
  end
end
