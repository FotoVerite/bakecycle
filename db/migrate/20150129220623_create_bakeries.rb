class CreateBakeries < ActiveRecord::Migration
  def change
    create_table :bakeries do |t|
      t.string :name

      t.timestamps
    end

    add_index :bakeries, :name, unique: true
  end
end
