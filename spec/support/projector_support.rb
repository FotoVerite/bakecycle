def mock_product_info(product, order_quantity)
  overbake_quantity = (order_quantity * product.over_bake / 100).ceil
  total_quantity = order_quantity + overbake_quantity
  OpenStruct.new(
    product: product,
    order_quantity: order_quantity,
    overbake_quantity: overbake_quantity,
    total_quantity: total_quantity
  )
end
