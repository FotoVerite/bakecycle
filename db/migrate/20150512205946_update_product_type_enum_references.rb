class UpdateProductTypeEnumReferences < ActiveRecord::Migration
  def change
    Product.where(product_type: 0).update_all(product_type: 10)
    Product.where(product_type: 2).update_all(product_type: 11)
    Product.where(product_type: 6).update_all(product_type: 12)
    Product.where(product_type: 4).update_all(product_type: 13)
    Product.where(product_type: 5).update_all(product_type: 14)
    Product.where(product_type: 3).update_all(product_type: 15)
    Product.where(product_type: 1).update_all(product_type: 16)
    Product.where(product_type: 7).update_all(product_type: 17)
    Product.where(product_type: 8).update_all(product_type: 18)
  end
end
