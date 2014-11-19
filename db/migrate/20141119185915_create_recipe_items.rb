class CreateRecipeItems < ActiveRecord::Migration
  def change
    create_table :recipe_items do |t|
      t.belongs_to :recipe
      t.references :inclusionable, polymorphic: true
      t.decimal :bakers_percentage, default: 0, null: false

      t.timestamps
    end
  end
end
