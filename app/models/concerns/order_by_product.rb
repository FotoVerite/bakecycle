module OrderByProduct
  def order_by_product_name
    includes(:product).order("products.name asc")
  end

  def order_by_product_type_and_name
    includes(:product).order("products.product_type asc, products.name asc")
  end
end
