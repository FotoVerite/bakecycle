class AddPlansForBakery < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name, null: false
      t.string :display_name, null: false
      t.timestamps
    end

    add_index :plans, :name, unique: true

    Plan.connection.execute <<-SQL
      INSERT INTO plans (name, display_name)
      VALUES ('beta_large', 'Large Bakery')
    SQL

    add_column :bakeries, :plan_id, :integer

    Bakery.connection.execute <<-SQL
      UPDATE bakeries
      SET plan_id = 1
      WHERE plan_id IS NULL
    SQL

    change_column :bakeries, :plan_id, :integer, null: false
    add_foreign_key "bakeries", "plans"
  end
end
