class CreateFileExports < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :file_exports, id: :uuid do |t|
      t.integer :bakery_id, null: false
      t.attachment :file
      t.string :file_fingerprint
      t.timestamps null: false
    end
    add_foreign_key :file_exports, :bakeries, on_delete: :cascade
    add_index :file_exports, :bakery_id
  end
end
