class AddNewForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key "production_runs", "bakeries", name: "production_runs_bakery_id_fk"
    add_foreign_key "run_items", "products", name: "run_items_product_id_fk"
    add_foreign_key "run_items", "production_runs", name: "run_items_production_run_id_fk", on_delete: :cascade
    add_foreign_key "shipment_items", "production_runs",
      name: "shipment_items_production_run_id_fk",
      on_delete: :nullify
  end
end
