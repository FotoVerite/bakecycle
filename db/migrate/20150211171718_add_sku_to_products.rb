# frozen_string_literal: true

class AddSkuToProducts < ActiveRecord::Migration
  def change
    add_column :products, :sku, :string
  end
end
