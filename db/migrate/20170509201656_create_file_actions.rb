class CreateFileActions < ActiveRecord::Migration
  def change
    create_table :file_actions do |t|
      t.belongs_to :user, index: true
      t.belongs_to :bakery, index: true
      t.belongs_to :file_export, type: :uuid, index: true
      t.string :action
      t.timestamps null: false
    end
  end
end
