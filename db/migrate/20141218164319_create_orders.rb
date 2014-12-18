class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :client
      t.belongs_to :route
      t.date :start_date
      t.date :end_date
      t.string :note
    end
  end
end
