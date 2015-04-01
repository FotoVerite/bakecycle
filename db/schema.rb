# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150331152443) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bakeries", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",             limit: 255
    t.string   "phone_number",      limit: 255
    t.string   "address_street_1",  limit: 255
    t.string   "address_street_2",  limit: 255
    t.string   "address_city",      limit: 255
    t.string   "address_state",     limit: 255
    t.string   "address_zipcode",   limit: 255
    t.string   "logo_file_name",    limit: 255
    t.string   "logo_content_type", limit: 255
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.time     "kickoff_time",                  null: false
    t.datetime "last_kickoff"
  end

  add_index "bakeries", ["name"], name: "index_bakeries_on_name", unique: true, using: :btree

  create_table "clients", force: :cascade do |t|
    t.string   "name",                           limit: 255
    t.string   "dba",                            limit: 255
    t.string   "business_phone",                 limit: 255
    t.string   "business_fax",                   limit: 255
    t.boolean  "active",                                                   null: false
    t.string   "delivery_address_street_1",      limit: 255
    t.string   "delivery_address_street_2",      limit: 255
    t.string   "delivery_address_city",          limit: 255
    t.string   "delivery_address_state",         limit: 255
    t.string   "delivery_address_zipcode",       limit: 255
    t.string   "billing_address_street_1",       limit: 255
    t.string   "billing_address_street_2",       limit: 255
    t.string   "billing_address_city",           limit: 255
    t.string   "billing_address_state",          limit: 255
    t.string   "billing_address_zipcode",        limit: 255
    t.string   "accounts_payable_contact_name",  limit: 255
    t.string   "accounts_payable_contact_phone", limit: 255
    t.string   "accounts_payable_contact_email", limit: 255
    t.string   "primary_contact_name",           limit: 255
    t.string   "primary_contact_phone",          limit: 255
    t.string   "primary_contact_email",          limit: 255
    t.string   "secondary_contact_name",         limit: 255
    t.string   "secondary_contact_phone",        limit: 255
    t.string   "secondary_contact_email",        limit: 255
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "billing_term",                                             null: false
    t.integer  "bakery_id",                                                null: false
    t.decimal  "delivery_minimum",                           default: 0.0, null: false
    t.decimal  "delivery_fee",                               default: 0.0, null: false
    t.string   "legacy_id",                      limit: 255
    t.integer  "delivery_fee_option",                                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "clients", ["active"], name: "index_clients_on_active", using: :btree
  add_index "clients", ["legacy_id", "bakery_id"], name: "index_clients_on_legacy_id_and_bakery_id", unique: true, using: :btree
  add_index "clients", ["name", "bakery_id"], name: "index_clients_on_name_and_bakery_id", unique: true, using: :btree

  create_table "ingredients", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.decimal  "price"
    t.decimal  "measure"
    t.integer  "unit"
    t.integer  "ingredient_type"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bakery_id",                   null: false
  end

  add_index "ingredients", ["name", "bakery_id"], name: "index_ingredients_on_name_and_bakery_id", unique: true, using: :btree

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "monday"
    t.integer  "tuesday"
    t.integer  "wednesday"
    t.integer  "thursday"
    t.integer  "friday"
    t.integer  "saturday"
    t.integer  "sunday"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "client_id"
    t.integer  "route_id"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "note",       limit: 255
    t.string   "order_type", limit: 255, null: false
    t.integer  "bakery_id",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "price_varients", force: :cascade do |t|
    t.integer  "product_id"
    t.decimal  "price",      default: 0.0, null: false
    t.integer  "quantity",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "price_varients", ["product_id", "quantity"], name: "unique_price_varient_quantity", unique: true, using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "product_type"
    t.decimal  "weight"
    t.integer  "unit"
    t.text     "description"
    t.decimal  "over_bake",                  default: 0.0, null: false
    t.integer  "motherdough_id"
    t.integer  "inclusion_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "base_price"
    t.integer  "bakery_id",                                null: false
    t.string   "sku",            limit: 255
  end

  add_index "products", ["name", "bakery_id"], name: "index_products_on_name_and_bakery_id", unique: true, using: :btree

  create_table "recipe_items", force: :cascade do |t|
    t.integer  "recipe_id"
    t.integer  "inclusionable_id"
    t.string   "inclusionable_type", limit: 255
    t.decimal  "bakers_percentage",              default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipes", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.text     "note"
    t.decimal  "mix_size"
    t.integer  "mix_size_unit"
    t.integer  "recipe_type"
    t.integer  "lead_days",                 default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bakery_id",                             null: false
  end

  add_index "recipes", ["name", "bakery_id"], name: "index_recipes_on_name_and_bakery_id", unique: true, using: :btree

  create_table "routes", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.text     "notes"
    t.boolean  "active",                     null: false
    t.time     "departure_time"
    t.integer  "bakery_id",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "routes", ["name", "bakery_id"], name: "index_routes_on_name_and_bakery_id", unique: true, using: :btree

  create_table "shipment_items", force: :cascade do |t|
    t.integer  "shipment_id"
    t.integer  "product_id"
    t.string   "product_name",     limit: 255
    t.integer  "product_quantity",             default: 0,   null: false
    t.decimal  "product_price",                default: 0.0, null: false
    t.string   "product_sku",      limit: 255
    t.date     "production_start",                           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipments", force: :cascade do |t|
    t.integer  "client_id"
    t.integer  "route_id"
    t.date     "date"
    t.date     "payment_due_date"
    t.integer  "bakery_id",                                                    null: false
    t.decimal  "delivery_fee",                                 default: 0.0,   null: false
    t.boolean  "auto_generated",                               default: false, null: false
    t.string   "client_name",                      limit: 255
    t.string   "client_dba",                       limit: 255
    t.string   "client_billing_term",              limit: 255
    t.string   "client_delivery_address_street_1", limit: 255
    t.string   "client_delivery_address_street_2", limit: 255
    t.string   "client_delivery_address_city",     limit: 255
    t.string   "client_delivery_address_state",    limit: 255
    t.string   "client_delivery_address_zipcode",  limit: 255
    t.string   "client_billing_address_street_1",  limit: 255
    t.string   "client_billing_address_street_2",  limit: 255
    t.string   "client_billing_address_city",      limit: 255
    t.string   "client_billing_address_state",     limit: 255
    t.string   "client_billing_address_zipcode",   limit: 255
    t.integer  "client_billing_term_days"
    t.string   "route_name",                       limit: 255
    t.string   "note",                             limit: 255
    t.string   "client_primary_contact_name",      limit: 255
    t.string   "client_primary_contact_phone",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "name",                   limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bakery_id"
    t.boolean  "admin",                              default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "clients", "bakeries", name: "clients_bakery_id_fk"
  add_foreign_key "ingredients", "bakeries", name: "ingredients_bakery_id_fk"
  add_foreign_key "order_items", "orders", name: "order_items_order_id_fk", on_delete: :cascade
  add_foreign_key "order_items", "products", name: "order_items_product_id_fk"
  add_foreign_key "orders", "bakeries", name: "orders_bakery_id_fk"
  add_foreign_key "orders", "clients", name: "orders_client_id_fk"
  add_foreign_key "orders", "routes", name: "orders_route_id_fk"
  add_foreign_key "price_varients", "products", name: "price_varients_product_id_fk", on_delete: :cascade
  add_foreign_key "products", "bakeries", name: "products_bakery_id_fk"
  add_foreign_key "products", "recipes", column: "inclusion_id", name: "products_inclusion_id_fk"
  add_foreign_key "products", "recipes", column: "motherdough_id", name: "products_motherdough_id_fk"
  add_foreign_key "recipe_items", "recipes", name: "recipe_items_recipe_id_fk", on_delete: :cascade
  add_foreign_key "recipes", "bakeries", name: "recipes_bakery_id_fk"
  add_foreign_key "routes", "bakeries", name: "routes_bakery_id_fk"
  add_foreign_key "shipment_items", "shipments", name: "shipment_items_shipment_id_fk", on_delete: :cascade
  add_foreign_key "shipments", "bakeries", name: "shipments_bakery_id_fk"
  add_foreign_key "users", "bakeries", name: "users_bakery_id_fk"
end
