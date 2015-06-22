class AddPlansForBakery < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name, null: false
      t.string :display_name, null: false
      t.timestamps
    end

    add_index :plans, :name, unique: true

    Plan.connection.execute <<-eos
      INSERT INTO plans (name, display_name)
      VALUES ('beta_large', 'Large Bakery')
    eos

    add_column :bakeries, :plan_id, :integer

    Bakery.connection.execute <<-eos
      UPDATE bakeries
      SET plan_id = 1
      WHERE plan_id IS NULL
    eos

    change_column :bakeries, :plan_id, :integer, null: false
    add_foreign_key 'bakeries', 'plans'
  end
end
