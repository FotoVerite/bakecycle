# frozen_string_literal: true

class AddOnViennPickToProducts < ActiveRecord::Migration[8.1]
  def up
    add_column :products, :on_vienn_pick, :boolean, default: false, null: false

    # Preserve today's behavior: the Vienn Pick sheet currently lists every
    # non-pull-list vienoisserie product, inferred from product_type rather
    # than an explicit flag. Backfill that same set into the new column so
    # switching BakeListData over to read it doesn't change what shows up.
    execute <<~SQL.squish
      UPDATE products SET on_vienn_pick = true
      WHERE product_type = 16 AND on_pull_list = false
    SQL
  end

  def down
    remove_column :products, :on_vienn_pick
  end
end
