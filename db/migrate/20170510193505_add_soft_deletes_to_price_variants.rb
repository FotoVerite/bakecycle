class AddSoftDeletesToPriceVariants < ActiveRecord::Migration
  def change
    add_column :price_variants, :removed, :integer, index: true, default: false
  end
end
