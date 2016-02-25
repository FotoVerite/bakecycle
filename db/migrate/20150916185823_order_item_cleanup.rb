# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
class OrderItemCleanup < ActiveRecord::Migration
  def change
    change_column_null :order_items, :monday, false
    change_column_null :order_items, :tuesday, false
    change_column_null :order_items, :wednesday, false
    change_column_null :order_items, :thursday, false
    change_column_null :order_items, :friday, false
    change_column_null :order_items, :saturday, false
    change_column_null :order_items, :sunday, false
    change_column_null :order_items, :order_id, false
    change_column_null :order_items, :product_id, false

    change_column_null :order_items, :created_at, false
    change_column_null :order_items, :updated_at, false

    change_column_null :clients, :created_at, false
    change_column_null :clients, :updated_at, false

    change_column_null :bakeries, :created_at, false
    change_column_null :bakeries, :updated_at, false

    change_column_null :ingredients, :created_at, false
    change_column_null :ingredients, :updated_at, false

    change_column_null :orders, :created_at, false
    change_column_null :orders, :updated_at, false

    change_column_null :plans, :created_at, false
    change_column_null :plans, :updated_at, false

    change_column_null :products, :created_at, false
    change_column_null :products, :updated_at, false

    change_column_null :recipe_items, :created_at, false
    change_column_null :recipe_items, :updated_at, false

    change_column_null :routes, :created_at, false
    change_column_null :routes, :updated_at, false

    change_column_null :shipment_items, :created_at, false
    change_column_null :shipment_items, :updated_at, false

    change_column_null :shipments, :created_at, false
    change_column_null :shipments, :updated_at, false

    change_column_null :users, :created_at, false
    change_column_null :users, :updated_at, false
  end
end
