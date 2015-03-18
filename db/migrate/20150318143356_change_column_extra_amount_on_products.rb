class ChangeColumnExtraAmountOnProducts < ActiveRecord::Migration
  def up
    rename_column :products, :extra_amount, :over_bake
    change_column :products, :over_bake, :decimal, default: 0.0, null: false
  end

  def down
    change_column :products, :over_bake, :decimal
    rename_column :products, :over_bake, :extra_amount
  end
end
