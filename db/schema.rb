# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_30_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"
  enable_extension "uuid-ossp"

  create_table "bakeries", id: :serial, force: :cascade do |t|
    t.string "address_city"
    t.string "address_state"
    t.string "address_street_1"
    t.string "address_street_2"
    t.string "address_zipcode"
    t.datetime "created_at", precision: nil, null: false
    t.string "email"
    t.json "graph_data"
    t.boolean "group_preferments", default: true
    t.time "kickoff_time", null: false
    t.datetime "last_kickoff", precision: nil
    t.string "logo_content_type"
    t.string "logo_file_name"
    t.integer "logo_file_size"
    t.datetime "logo_updated_at", precision: nil
    t.string "name"
    t.string "phone_number"
    t.integer "plan_id", null: false
    t.string "quickbooks_account", null: false
    t.string "stripe_customer_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_bakeries_on_name", unique: true
  end

  create_table "bakery_assignments", id: :serial, force: :cascade do |t|
    t.integer "bakery_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
  end

  create_table "buy_orders", force: :cascade do |t|
    t.decimal "amount", default: "0.0", null: false
    t.bigint "bakery_id"
    t.datetime "created_at", precision: nil, null: false
    t.bigint "ingredient_id"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "vendor_id"
    t.index ["bakery_id"], name: "index_buy_orders_on_bakery_id"
    t.index ["ingredient_id"], name: "index_buy_orders_on_ingredient_id"
    t.index ["vendor_id"], name: "index_buy_orders_on_vendor_id"
  end

  create_table "clients", id: :serial, force: :cascade do |t|
    t.string "accounts_payable_contact_email"
    t.string "accounts_payable_contact_name"
    t.string "accounts_payable_contact_phone"
    t.boolean "active", null: false
    t.boolean "alert", default: false
    t.integer "bakery_id", null: false
    t.string "billing_address_city"
    t.string "billing_address_state"
    t.string "billing_address_street_1"
    t.string "billing_address_street_2"
    t.string "billing_address_zipcode"
    t.integer "billing_term", null: false
    t.string "business_fax"
    t.string "business_phone"
    t.string "channel"
    t.datetime "created_at", precision: nil, null: false
    t.integer "default_discount_type"
    t.decimal "default_discount_value", precision: 10, scale: 2
    t.string "delivery_address_city"
    t.string "delivery_address_state"
    t.string "delivery_address_street_1"
    t.string "delivery_address_street_2"
    t.string "delivery_address_zipcode"
    t.decimal "delivery_fee", default: "0.0", null: false
    t.integer "delivery_fee_option", null: false
    t.decimal "delivery_minimum", default: "0.0", null: false
    t.string "ein"
    t.integer "engagement_status", default: 0, null: false
    t.string "group"
    t.float "latitude"
    t.string "legacy_id"
    t.float "longitude"
    t.string "name"
    t.string "notes"
    t.string "official_company_name"
    t.string "primary_contact_email"
    t.string "primary_contact_name"
    t.string "primary_contact_phone"
    t.boolean "print_invoice", default: true
    t.string "secondary_contact_email"
    t.string "secondary_contact_name"
    t.string "secondary_contact_phone"
    t.boolean "send_shipment_when_generated", default: false
    t.integer "sequence_number", default: 1
    t.boolean "temp_vip", default: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "wholesale_manager"
    t.index ["active"], name: "index_clients_on_active"
    t.index ["legacy_id", "bakery_id"], name: "index_clients_on_legacy_id_and_bakery_id", unique: true
    t.index ["name", "bakery_id"], name: "index_clients_on_name_and_bakery_id", unique: true
  end

  create_table "file_actions", id: :serial, force: :cascade do |t|
    t.string "action"
    t.integer "bakery_id"
    t.datetime "created_at", precision: nil, null: false
    t.uuid "file_export_id"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["bakery_id"], name: "index_file_actions_on_bakery_id"
    t.index ["file_export_id"], name: "index_file_actions_on_file_export_id"
    t.index ["user_id"], name: "index_file_actions_on_user_id"
  end

  create_table "file_exports", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "bakery_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "file_content_type"
    t.string "file_file_name"
    t.integer "file_file_size"
    t.string "file_fingerprint"
    t.datetime "file_updated_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.index ["bakery_id"], name: "index_file_exports_on_bakery_id"
  end

  create_table "ingredient_prices_over_times", force: :cascade do |t|
    t.bigint "bakery_id"
    t.decimal "conversion"
    t.decimal "cost_per_gram"
    t.decimal "cost_per_unit"
    t.datetime "created_at", precision: nil, null: false
    t.bigint "ingredient_id"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "vendor_id"
    t.string "weight_unit"
    t.index ["bakery_id"], name: "index_ingredient_prices_over_times_on_bakery_id"
    t.index ["ingredient_id"], name: "index_ingredient_prices_over_times_on_ingredient_id"
    t.index ["vendor_id"], name: "index_ingredient_prices_over_times_on_vendor_id"
  end

  create_table "ingredients", id: :serial, force: :cascade do |t|
    t.integer "bakery_id", null: false
    t.decimal "conversion", default: "1.0"
    t.decimal "cost_per_gram"
    t.datetime "created_at", precision: nil, null: false
    t.decimal "current_amount", default: "0.0", null: false
    t.text "description"
    t.boolean "inactive", default: false
    t.string "ingredient_type", default: "other", null: false
    t.string "legacy_id"
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "vendor_id"
    t.string "weight_unit", default: "grams"
    t.index ["legacy_id", "bakery_id"], name: "index_ingredients_on_legacy_id_and_bakery_id", unique: true
    t.index ["name", "bakery_id"], name: "index_ingredients_on_name_and_bakery_id", unique: true
  end

  create_table "order_items", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "friday", null: false
    t.integer "monday", null: false
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.integer "removed", default: 0
    t.integer "saturday", null: false
    t.integer "sunday", null: false
    t.integer "thursday", null: false
    t.integer "total_lead_days", null: false
    t.integer "tuesday", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "wednesday", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["total_lead_days"], name: "index_order_items_on_total_lead_days"
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.boolean "alert", default: false
    t.integer "bakery_id", null: false
    t.integer "client_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_user_id"
    t.decimal "discount"
    t.date "end_date"
    t.integer "last_updated_by_user_id"
    t.integer "legacy_id"
    t.text "note", default: "", null: false
    t.string "order_type", null: false
    t.integer "route_id"
    t.date "start_date", null: false
    t.integer "total_lead_days", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "version_number", default: 0
    t.index ["bakery_id", "start_date", "end_date"], name: "index_orders_on_bakery_id_and_start_date_and_end_date"
    t.index ["bakery_id"], name: "index_orders_on_bakery_id"
    t.index ["client_id", "route_id", "start_date", "end_date", "order_type"], name: "orders_idx_nulls_start", order: { end_date: "NULLS FIRST" }
    t.index ["created_by_user_id"], name: "index_orders_on_created_by_user_id"
    t.index ["end_date"], name: "index_orders_on_end_date"
    t.index ["last_updated_by_user_id"], name: "index_orders_on_last_updated_by_user_id"
    t.index ["legacy_id", "bakery_id"], name: "index_orders_on_legacy_id_and_bakery_id", unique: true
    t.index ["order_type"], name: "index_orders_on_order_type"
    t.index ["start_date", "end_date"], name: "index_orders_on_start_date_and_end_date"
    t.index ["start_date"], name: "index_orders_on_start_date"
  end

  create_table "plans", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "display_name", null: false
    t.string "name", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_plans_on_name", unique: true
  end

  create_table "price_variants", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.datetime "created_at", precision: nil
    t.decimal "price", default: "0.0", null: false
    t.integer "product_id", null: false
    t.integer "quantity", null: false
    t.integer "removed", default: 0
    t.datetime "updated_at", precision: nil
    t.index ["product_id"], name: "index_price_variants_on_product_id"
    t.index ["quantity", "product_id", "client_id"], name: "index_price_variants_on_quantity_and_product_id_and_client_id", unique: true
  end

  create_table "product_graph_data", force: :cascade do |t|
    t.decimal "amount"
    t.bigint "bakery_id"
    t.datetime "created_at", precision: nil, null: false
    t.date "date"
    t.bigint "product_id"
    t.integer "shipment_count"
    t.integer "shipped"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["bakery_id"], name: "index_product_graph_data_on_bakery_id"
    t.index ["product_id"], name: "index_product_graph_data_on_product_id"
  end

  create_table "production_runs", id: :serial, force: :cascade do |t|
    t.integer "bakery_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.date "date", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["bakery_id", "date"], name: "index_production_runs_on_bakery_id_and_date"
    t.index ["bakery_id"], name: "index_production_runs_on_bakery_id"
  end

  create_table "products", id: :serial, force: :cascade do |t|
    t.integer "bakery_id", null: false
    t.decimal "base_price", null: false
    t.boolean "batch_recipe", default: false
    t.decimal "cog"
    t.datetime "created_at", precision: nil, null: false
    t.text "description"
    t.json "graph_data"
    t.boolean "inactive", default: false
    t.integer "inclusion_id"
    t.integer "lead_days_override", default: 1
    t.string "legacy_id"
    t.integer "motherdough_id"
    t.string "name", null: false
    t.decimal "over_bake", default: "0.0", null: false
    t.integer "product_type", null: false
    t.boolean "public", default: false
    t.boolean "removed", default: false
    t.string "sku"
    t.integer "total_lead_days", null: false
    t.integer "unit", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.decimal "weight", null: false
    t.index ["legacy_id", "bakery_id"], name: "index_products_on_legacy_id_and_bakery_id", unique: true
    t.index ["name", "bakery_id"], name: "index_products_on_name_and_bakery_id", unique: true
    t.index ["removed"], name: "index_products_on_removed"
  end

  create_table "public_client_users", force: :cascade do |t|
    t.bigint "bakery_id"
    t.bigint "client_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["bakery_id"], name: "index_public_client_users_on_bakery_id"
    t.index ["client_id"], name: "index_public_client_users_on_client_id"
  end

  create_table "recipe_items", id: :serial, force: :cascade do |t|
    t.decimal "bakers_percentage", default: "0.0", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "inclusionable_id"
    t.string "inclusionable_type"
    t.integer "recipe_id", null: false
    t.integer "removed", default: 0
    t.integer "sort_id", default: 0, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["recipe_id", "inclusionable_type", "inclusionable_id"], name: "index_recipe_items_on_recipe_id_and_inclusionable"
  end

  create_table "recipes", id: :serial, force: :cascade do |t|
    t.integer "bakery_id", null: false
    t.datetime "created_at", precision: nil
    t.integer "lead_days", default: 0, null: false
    t.string "legacy_id"
    t.decimal "mix_size"
    t.integer "mix_size_unit"
    t.string "name"
    t.text "note"
    t.integer "recipe_type"
    t.integer "total_lead_days", null: false
    t.datetime "updated_at", precision: nil
    t.index ["legacy_id", "bakery_id"], name: "index_recipes_on_legacy_id_and_bakery_id", unique: true
    t.index ["name", "bakery_id"], name: "index_recipes_on_name_and_bakery_id", unique: true
  end

  create_table "routes", id: :serial, force: :cascade do |t|
    t.boolean "active", null: false
    t.integer "bakery_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.time "departure_time", null: false
    t.integer "legacy_id"
    t.string "name"
    t.text "notes"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["legacy_id", "bakery_id"], name: "index_routes_on_legacy_id_and_bakery_id", unique: true
    t.index ["name", "bakery_id"], name: "index_routes_on_name_and_bakery_id", unique: true
  end

  create_table "run_items", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "order_quantity"
    t.integer "overbake_quantity"
    t.integer "product_id", null: false
    t.integer "production_run_id", null: false
    t.integer "total_quantity"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["production_run_id", "product_id"], name: "index_run_items_on_production_run_id_and_product_id", unique: true
  end

  create_table "shipment_graph_data", force: :cascade do |t|
    t.decimal "amount", default: "0.0", null: false
    t.bigint "bakery_id"
    t.datetime "created_at", precision: nil, null: false
    t.date "date"
    t.integer "product_count"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["bakery_id"], name: "index_shipment_graph_data_on_bakery_id"
    t.index ["date"], name: "index_shipment_graph_data_on_date"
  end

  create_table "shipment_items", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "product_id"
    t.string "product_name"
    t.decimal "product_price", default: "0.0", null: false
    t.string "product_product_type", null: false
    t.integer "product_quantity", default: 0, null: false
    t.string "product_sku"
    t.integer "product_total_lead_days", null: false
    t.integer "production_run_id"
    t.date "production_start", null: false
    t.integer "shipment_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["production_run_id"], name: "index_shipment_items_on_production_run_id"
    t.index ["shipment_id"], name: "index_shipment_items_on_shipment_id"
  end

  create_table "shipments", id: :serial, force: :cascade do |t|
    t.boolean "alert", default: false
    t.boolean "auto_generated", default: false, null: false
    t.integer "bakery_id", null: false
    t.decimal "cached_price"
    t.string "client_billing_address_city"
    t.string "client_billing_address_state"
    t.string "client_billing_address_street_1"
    t.string "client_billing_address_street_2"
    t.string "client_billing_address_zipcode"
    t.string "client_billing_term", null: false
    t.integer "client_billing_term_days", null: false
    t.string "client_delivery_address_city"
    t.string "client_delivery_address_state"
    t.string "client_delivery_address_street_1"
    t.string "client_delivery_address_street_2"
    t.string "client_delivery_address_zipcode"
    t.integer "client_id", null: false
    t.string "client_name", null: false
    t.string "client_notes"
    t.string "client_official_company_name"
    t.string "client_primary_contact_name"
    t.string "client_primary_contact_phone"
    t.datetime "created_at", precision: nil, null: false
    t.date "date", null: false
    t.decimal "delivery_fee", default: "0.0", null: false
    t.decimal "discount"
    t.integer "discount_type"
    t.decimal "discount_value", precision: 10, scale: 2
    t.text "note"
    t.integer "order_id"
    t.date "payment_due_date", null: false
    t.string "po_number"
    t.time "route_departure_time", null: false
    t.integer "route_id", null: false
    t.string "route_name", null: false
    t.boolean "sent", default: false
    t.integer "sequence_number"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["bakery_id"], name: "index_shipments_on_bakery_id"
    t.index ["client_id", "route_id", "date"], name: "index_shipments_on_client_id_and_route_id_and_date"
    t.index ["order_id", "date"], name: "index_shipments_on_order_id_and_date"
    t.index ["order_id"], name: "index_shipments_on_order_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "user_pinned_actions", force: :cascade do |t|
    t.string "action_key", null: false
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "action_key"], name: "index_user_pinned_actions_on_user_id_and_action_key", unique: true
    t.index ["user_id", "position"], name: "index_user_pinned_actions_on_user_id_and_position"
    t.index ["user_id"], name: "index_user_pinned_actions_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.boolean "admin", default: false
    t.integer "bakery_id"
    t.string "bakery_permission", default: "none", null: false
    t.string "client_permission", default: "none", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "invitation_accepted_at", precision: nil
    t.datetime "invitation_created_at", precision: nil
    t.integer "invitation_limit"
    t.datetime "invitation_sent_at", precision: nil
    t.string "invitation_token"
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.datetime "last_sign_in_at", precision: nil
    t.inet "last_sign_in_ip"
    t.string "name", default: "", null: false
    t.string "product_permission", default: "none", null: false
    t.string "production_permission", default: "none", null: false
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.string "shipping_permission", default: "none", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "user_permission", default: "none", null: false
    t.index ["bakery_id"], name: "index_users_on_bakery_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vendors", force: :cascade do |t|
    t.bigint "bakery_id"
    t.string "contact"
    t.datetime "created_at", precision: nil, null: false
    t.string "email"
    t.string "name"
    t.string "phone"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["bakery_id"], name: "index_vendors_on_bakery_id"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "event", null: false
    t.integer "item_id", null: false
    t.string "item_type", null: false
    t.text "object"
    t.text "object_changes"
    t.string "whodunnit"
    t.index ["created_at"], name: "index_versions_on_created_at"
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
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "user_pinned_actions", "users"
  add_foreign_key "users", "bakeries", name: "users_bakery_id_fk"
end
