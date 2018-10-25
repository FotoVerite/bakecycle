# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20181025054307) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"
  enable_extension "uuid-ossp"

  create_table "bakeries", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "phone_number"
    t.string "address_street_1"
    t.string "address_street_2"
    t.string "address_city"
    t.string "address_state"
    t.string "address_zipcode"
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.integer "logo_file_size"
    t.datetime "logo_updated_at"
    t.time "kickoff_time", null: false
    t.datetime "last_kickoff"
    t.string "quickbooks_account", null: false
    t.boolean "group_preferments", default: true
    t.integer "plan_id", null: false
    t.string "stripe_customer_id"
    t.json "graph_data"
    t.index ["name"], name: "index_bakeries_on_name", unique: true
  end

  create_table "bakery_assignments", id: :serial, force: :cascade do |t|
    t.integer "bakery_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "brands", force: :cascade do |t|
    t.bigint "ingredient_id"
    t.bigint "bakery_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "#<ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition"
    t.index ["bakery_id"], name: "index_brands_on_bakery_id"
    t.index ["ingredient_id"], name: "index_brands_on_ingredient_id"
  end

  create_table "buy_orders", force: :cascade do |t|
    t.bigint "vendor_id"
    t.bigint "ingredient_id"
    t.bigint "bakery_id"
    t.decimal "amount", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bakery_id"], name: "index_buy_orders_on_bakery_id"
    t.index ["ingredient_id"], name: "index_buy_orders_on_ingredient_id"
    t.index ["vendor_id"], name: "index_buy_orders_on_vendor_id"
  end

  create_table "client_organizations", force: :cascade do |t|
    t.string "name"
    t.bigint "bakery_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bakery_id"], name: "index_client_organizations_on_bakery_id"
  end

  create_table "clients", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "official_company_name"
    t.string "business_phone"
    t.string "business_fax"
    t.boolean "active", null: false
    t.string "delivery_address_street_1"
    t.string "delivery_address_street_2"
    t.string "delivery_address_city"
    t.string "delivery_address_state"
    t.string "delivery_address_zipcode"
    t.string "billing_address_street_1"
    t.string "billing_address_street_2"
    t.string "billing_address_city"
    t.string "billing_address_state"
    t.string "billing_address_zipcode"
    t.string "accounts_payable_contact_name"
    t.string "accounts_payable_contact_phone"
    t.string "accounts_payable_contact_email"
    t.string "primary_contact_name"
    t.string "primary_contact_phone"
    t.string "primary_contact_email"
    t.string "secondary_contact_name"
    t.string "secondary_contact_phone"
    t.string "secondary_contact_email"
    t.float "latitude"
    t.float "longitude"
    t.integer "billing_term", null: false
    t.integer "bakery_id", null: false
    t.decimal "delivery_minimum", default: "0.0", null: false
    t.decimal "delivery_fee", default: "0.0", null: false
    t.string "legacy_id"
    t.integer "delivery_fee_option", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ein"
    t.string "notes"
    t.integer "sequence_number", default: 1
    t.boolean "alert", default: false
    t.boolean "print_invoice", default: true
    t.boolean "temp_vip", default: false
    t.string "wholesale_manager"
    t.index ["active"], name: "index_clients_on_active"
    t.index ["legacy_id", "bakery_id"], name: "index_clients_on_legacy_id_and_bakery_id", unique: true
    t.index ["name", "bakery_id"], name: "index_clients_on_name_and_bakery_id", unique: true
  end

  create_table "file_actions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "bakery_id"
    t.uuid "file_export_id"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bakery_id"], name: "index_file_actions_on_bakery_id"
    t.index ["file_export_id"], name: "index_file_actions_on_file_export_id"
    t.index ["user_id"], name: "index_file_actions_on_user_id"
  end

  create_table "file_exports", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "bakery_id", null: false
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.string "file_fingerprint"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bakery_id"], name: "index_file_exports_on_bakery_id"
  end

  create_table "ingredient_prices_over_times", force: :cascade do |t|
    t.bigint "ingredient_id"
    t.bigint "vendor_id"
    t.bigint "bakery_id"
    t.string "weight_unit"
    t.decimal "conversion"
    t.decimal "cost_per_unit"
    t.decimal "cost_per_gram"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bakery_id"], name: "index_ingredient_prices_over_times_on_bakery_id"
    t.index ["ingredient_id"], name: "index_ingredient_prices_over_times_on_ingredient_id"
    t.index ["vendor_id"], name: "index_ingredient_prices_over_times_on_vendor_id"
  end

  create_table "ingredients", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "bakery_id", null: false
    t.string "legacy_id"
    t.string "ingredient_type", default: "other", null: false
    t.integer "vendor_id"
    t.decimal "current_amount", default: "0.0", null: false
    t.string "weight_unit", default: "grams"
    t.decimal "conversion", default: "1.0"
    t.decimal "cost_per_gram"
    t.boolean "inactive", default: false
    t.index ["legacy_id", "bakery_id"], name: "index_ingredients_on_legacy_id_and_bakery_id", unique: true
    t.index ["name", "bakery_id"], name: "index_ingredients_on_name_and_bakery_id", unique: true
  end

  create_table "order_items", id: :serial, force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.integer "monday", null: false
    t.integer "tuesday", null: false
    t.integer "wednesday", null: false
    t.integer "thursday", null: false
    t.integer "friday", null: false
    t.integer "saturday", null: false
    t.integer "sunday", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_lead_days", null: false
    t.integer "removed", default: 0
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["total_lead_days"], name: "index_order_items_on_total_lead_days"
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "route_id"
    t.date "start_date", null: false
    t.date "end_date"
    t.text "note", default: "", null: false
    t.string "order_type", null: false
    t.integer "bakery_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "legacy_id"
    t.integer "total_lead_days", null: false
    t.integer "version_number", default: 0
    t.integer "created_by_user_id"
    t.integer "last_updated_by_user_id"
    t.boolean "alert", default: false
    t.index ["bakery_id", "start_date", "end_date"], name: "index_orders_on_bakery_id_and_start_date_and_end_date"
    t.index ["bakery_id"], name: "index_orders_on_bakery_id"
    t.index ["client_id", "route_id", "start_date", "end_date", "order_type"], name: "orders_idx_nulls_start"
    t.index ["created_by_user_id"], name: "index_orders_on_created_by_user_id"
    t.index ["end_date"], name: "index_orders_on_end_date"
    t.index ["last_updated_by_user_id"], name: "index_orders_on_last_updated_by_user_id"
    t.index ["legacy_id", "bakery_id"], name: "index_orders_on_legacy_id_and_bakery_id", unique: true
    t.index ["order_type"], name: "index_orders_on_order_type"
    t.index ["start_date", "end_date"], name: "index_orders_on_start_date_and_end_date"
    t.index ["start_date"], name: "index_orders_on_start_date"
  end

  create_table "plans", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "display_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_plans_on_name", unique: true
  end

  create_table "price_variants", id: :serial, force: :cascade do |t|
    t.integer "product_id", null: false
    t.decimal "price", default: "0.0", null: false
    t.integer "quantity", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "client_id"
    t.integer "removed", default: 0
    t.index ["product_id"], name: "index_price_variants_on_product_id"
    t.index ["quantity", "product_id", "client_id"], name: "index_price_variants_on_quantity_and_product_id_and_client_id", unique: true
  end

  create_table "product_graph_data", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "bakery_id"
    t.date "date"
    t.integer "shipment_count"
    t.integer "shipped"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bakery_id"], name: "index_product_graph_data_on_bakery_id"
    t.index ["product_id"], name: "index_product_graph_data_on_product_id"
  end

  create_table "production_runs", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date", null: false
    t.integer "bakery_id", null: false
    t.index ["bakery_id", "date"], name: "index_production_runs_on_bakery_id_and_date"
    t.index ["bakery_id"], name: "index_production_runs_on_bakery_id"
  end

  create_table "products", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "product_type", null: false
    t.decimal "weight", null: false
    t.integer "unit", null: false
    t.text "description"
    t.decimal "over_bake", default: "0.0", null: false
    t.integer "motherdough_id"
    t.integer "inclusion_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "base_price", null: false
    t.integer "bakery_id", null: false
    t.string "sku"
    t.string "legacy_id"
    t.integer "total_lead_days", null: false
    t.boolean "batch_recipe", default: false
    t.boolean "removed", default: false
    t.json "graph_data"
    t.boolean "inactive", default: false
    t.decimal "cog"
    t.index ["legacy_id", "bakery_id"], name: "index_products_on_legacy_id_and_bakery_id", unique: true
    t.index ["name", "bakery_id"], name: "index_products_on_name_and_bakery_id", unique: true
    t.index ["removed"], name: "index_products_on_removed"
  end

  create_table "recipe_items", id: :serial, force: :cascade do |t|
    t.integer "recipe_id", null: false
    t.integer "inclusionable_id"
    t.string "inclusionable_type"
    t.decimal "bakers_percentage", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_id", default: 0, null: false
    t.integer "removed", default: 0
    t.index ["recipe_id", "inclusionable_type", "inclusionable_id"], name: "index_recipe_items_on_recipe_id_and_inclusionable"
  end

  create_table "recipes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "note"
    t.decimal "mix_size"
    t.integer "mix_size_unit"
    t.integer "recipe_type"
    t.integer "lead_days", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "bakery_id", null: false
    t.string "legacy_id"
    t.integer "total_lead_days", null: false
    t.index ["legacy_id", "bakery_id"], name: "index_recipes_on_legacy_id_and_bakery_id", unique: true
    t.index ["name", "bakery_id"], name: "index_recipes_on_name_and_bakery_id", unique: true
  end

  create_table "routes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "notes"
    t.boolean "active", null: false
    t.time "departure_time", null: false
    t.integer "bakery_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "legacy_id"
    t.index ["legacy_id", "bakery_id"], name: "index_routes_on_legacy_id_and_bakery_id", unique: true
    t.index ["name", "bakery_id"], name: "index_routes_on_name_and_bakery_id", unique: true
  end

  create_table "run_items", id: :serial, force: :cascade do |t|
    t.integer "production_run_id", null: false
    t.integer "product_id", null: false
    t.integer "total_quantity"
    t.integer "order_quantity"
    t.integer "overbake_quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["production_run_id", "product_id"], name: "index_run_items_on_production_run_id_and_product_id", unique: true
  end

  create_table "shipment_graph_data", force: :cascade do |t|
    t.bigint "bakery_id"
    t.integer "product_count"
    t.decimal "amount", default: "0.0", null: false
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bakery_id"], name: "index_shipment_graph_data_on_bakery_id"
    t.index ["date"], name: "index_shipment_graph_data_on_date"
  end

  create_table "shipment_items", id: :serial, force: :cascade do |t|
    t.integer "shipment_id"
    t.integer "product_id"
    t.string "product_name"
    t.integer "product_quantity", default: 0, null: false
    t.decimal "product_price", default: "0.0", null: false
    t.string "product_sku"
    t.date "production_start", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "production_run_id"
    t.string "product_product_type", null: false
    t.integer "product_total_lead_days", null: false
    t.index ["production_run_id"], name: "index_shipment_items_on_production_run_id"
    t.index ["shipment_id"], name: "index_shipment_items_on_shipment_id"
  end

  create_table "shipments", id: :serial, force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "route_id", null: false
    t.date "date", null: false
    t.date "payment_due_date", null: false
    t.integer "bakery_id", null: false
    t.decimal "delivery_fee", default: "0.0", null: false
    t.boolean "auto_generated", default: false, null: false
    t.string "client_name", null: false
    t.string "client_official_company_name"
    t.string "client_billing_term", null: false
    t.string "client_delivery_address_street_1"
    t.string "client_delivery_address_street_2"
    t.string "client_delivery_address_city"
    t.string "client_delivery_address_state"
    t.string "client_delivery_address_zipcode"
    t.string "client_billing_address_street_1"
    t.string "client_billing_address_street_2"
    t.string "client_billing_address_city"
    t.string "client_billing_address_state"
    t.string "client_billing_address_zipcode"
    t.integer "client_billing_term_days", null: false
    t.string "route_name", null: false
    t.text "note"
    t.string "client_primary_contact_name"
    t.string "client_primary_contact_phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.time "route_departure_time", null: false
    t.string "client_notes"
    t.integer "order_id"
    t.integer "sequence_number"
    t.boolean "alert", default: false
    t.index ["bakery_id"], name: "index_shipments_on_bakery_id"
    t.index ["client_id", "route_id", "date"], name: "index_shipments_on_client_id_and_route_id_and_date"
    t.index ["order_id", "date"], name: "index_shipments_on_order_id_and_date"
    t.index ["order_id"], name: "index_shipments_on_order_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "name", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "bakery_id"
    t.boolean "admin", default: false
    t.string "user_permission", default: "none", null: false
    t.string "product_permission", default: "none", null: false
    t.string "bakery_permission", default: "none", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.string "client_permission", default: "none", null: false
    t.string "shipping_permission", default: "none", null: false
    t.string "production_permission", default: "none", null: false
    t.index ["bakery_id"], name: "index_users_on_bakery_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vendors", force: :cascade do |t|
    t.bigint "bakery_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact"
    t.string "phone"
    t.string "email"
    t.index ["bakery_id"], name: "index_vendors_on_bakery_id"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "bakeries", "plans"
  add_foreign_key "clients", "bakeries", name: "clients_bakery_id_fk"
  add_foreign_key "file_exports", "bakeries", on_delete: :cascade
  add_foreign_key "ingredients", "bakeries", name: "ingredients_bakery_id_fk"
  add_foreign_key "order_items", "orders", name: "order_items_order_id_fk", on_delete: :cascade
  add_foreign_key "order_items", "products", name: "order_items_product_id_fk"
  add_foreign_key "orders", "bakeries", name: "orders_bakery_id_fk"
  add_foreign_key "orders", "clients", name: "orders_client_id_fk"
  add_foreign_key "orders", "routes", name: "orders_route_id_fk"
  add_foreign_key "price_variants", "clients", on_delete: :cascade
  add_foreign_key "price_variants", "products", name: "price_varients_product_id_fk", on_delete: :cascade
  add_foreign_key "production_runs", "bakeries", name: "production_runs_bakery_id_fk"
  add_foreign_key "products", "bakeries", name: "products_bakery_id_fk"
  add_foreign_key "products", "recipes", column: "inclusion_id", name: "products_inclusion_id_fk"
  add_foreign_key "products", "recipes", column: "motherdough_id", name: "products_motherdough_id_fk"
  add_foreign_key "recipe_items", "recipes", name: "recipe_items_recipe_id_fk", on_delete: :cascade
  add_foreign_key "recipes", "bakeries", name: "recipes_bakery_id_fk"
  add_foreign_key "routes", "bakeries", name: "routes_bakery_id_fk"
  add_foreign_key "run_items", "production_runs", name: "run_items_production_run_id_fk", on_delete: :cascade
  add_foreign_key "run_items", "products", name: "run_items_product_id_fk"
  add_foreign_key "shipment_items", "production_runs", name: "shipment_items_production_run_id_fk", on_delete: :nullify
  add_foreign_key "shipment_items", "shipments", name: "shipment_items_shipment_id_fk", on_delete: :cascade
  add_foreign_key "shipments", "bakeries", name: "shipments_bakery_id_fk"
  add_foreign_key "users", "bakeries", name: "users_bakery_id_fk"
end
