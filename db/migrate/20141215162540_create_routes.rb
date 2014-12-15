class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.string :name
      t.text :notes
      t.boolean :active
      t.time :departure_time
    end
  end
end
