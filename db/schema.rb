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

ActiveRecord::Schema.define(version: 20150310234313) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bakeries", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "phone_number"
    t.string   "address_street_1"
    t.string   "address_street_2"
    t.string   "address_city"
    t.string   "address_state"
    t.string   "address_zipcode"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  add_index "bakeries", ["name"], name: "index_bakeries_on_name", unique: true, using: :btree

  create_table "clients", force: true do |t|
    t.string  "name"
    t.string  "dba"
    t.string  "business_phone"
    t.string  "business_fax"
    t.boolean "active",                                       null: false
    t.string  "delivery_address_street_1"
    t.string  "delivery_address_street_2"
    t.string  "delivery_address_city"
    t.string  "delivery_address_state"
    t.string  "delivery_address_zipcode"
    t.string  "billing_address_street_1"
    t.string  "billing_address_street_2"
    t.string  "billing_address_city"
    t.string  "billing_address_state"
    t.string  "billing_address_zipcode"
    t.string  "accounts_payable_contact_name"
    t.string  "accounts_payable_contact_phone"
    t.string  "accounts_payable_contact_email"
    t.string  "primary_contact_name"
    t.string  "primary_contact_phone"
    t.string  "primary_contact_email"
    t.string  "secondary_contact_name"
    t.string  "secondary_contact_phone"
    t.string  "secondary_contact_email"
    t.float   "latitude"
    t.float   "longitude"
    t.integer "billing_term",                                 null: false
    t.integer "bakery_id"
    t.decimal "delivery_minimum",               default: 0.0, null: false
    t.decimal "delivery_fee",                   default: 0.0, null: false
    t.integer "delivery_fee_option",                          null: false
  end

  add_index "clients", ["active"], name: "index_clients_on_active", using: :btree
  add_index "clients", ["name", "bakery_id"], name: "index_clients_on_name_and_bakery_id", unique: true, using: :btree

  create_table "ingredients", force: true do |t|
    t.string   "name"
    t.decimal  "price"
    t.decimal  "measure"
    t.integer  "unit"
    t.integer  "ingredient_type"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bakery_id"
  end

  add_index "ingredients", ["name", "bakery_id"], name: "index_ingredients_on_name_and_bakery_id", unique: true, using: :btree

  create_table "order_items", force: true do |t|
    t.integer "order_id"
    t.integer "product_id"
    t.integer "monday"
    t.integer "tuesday"
    t.integer "wednesday"
    t.integer "thursday"
    t.integer "friday"
    t.integer "saturday"
    t.integer "sunday"
  end

  create_table "orders", force: true do |t|
    t.integer "client_id"
    t.integer "route_id"
    t.date    "start_date"
    t.date    "end_date"
    t.string  "note"
    t.string  "order_type", null: false
    t.integer "bakery_id"
  end

  create_table "price_varients", force: true do |t|
    t.integer  "product_id"
    t.decimal  "price",      default: 0.0, null: false
    t.integer  "quantity",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "price_varients", ["product_id", "quantity"], name: "unique_price_varient_quantity", unique: true, using: :btree

  create_table "products", force: true do |t|
    t.string   "name"
    t.integer  "product_type"
    t.decimal  "weight"
    t.integer  "unit"
    t.text     "description"
    t.decimal  "extra_amount"
    t.integer  "motherdough_id"
    t.integer  "inclusion_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "base_price"
    t.integer  "bakery_id"
    t.string   "sku"
  end

  add_index "products", ["name", "bakery_id"], name: "index_products_on_name_and_bakery_id", unique: true, using: :btree

  create_table "recipe_items", force: true do |t|
    t.integer  "recipe_id"
    t.integer  "inclusionable_id"
    t.string   "inclusionable_type"
    t.decimal  "bakers_percentage",  default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipes", force: true do |t|
    t.string   "name"
    t.text     "note"
    t.decimal  "mix_size"
    t.integer  "mix_size_unit"
    t.integer  "recipe_type"
    t.integer  "lead_days",     default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bakery_id"
  end

  add_index "recipes", ["name", "bakery_id"], name: "index_recipes_on_name_and_bakery_id", unique: true, using: :btree

  create_table "routes", force: true do |t|
    t.string  "name"
    t.text    "notes"
    t.boolean "active",         null: false
    t.time    "departure_time"
    t.integer "bakery_id"
  end

  add_index "routes", ["name", "bakery_id"], name: "index_routes_on_name_and_bakery_id", unique: true, using: :btree

  create_table "shipment_items", force: true do |t|
    t.integer "shipment_id"
    t.integer "product_id"
    t.string  "product_name"
    t.integer "product_quantity", default: 0,   null: false
    t.decimal "product_price",    default: 0.0, null: false
    t.string  "product_sku"
    t.date    "production_start",               null: false
  end

  create_table "shipments", force: true do |t|
    t.integer "client_id"
    t.integer "route_id"
    t.date    "date"
    t.date    "payment_due_date"
    t.integer "bakery_id"
    t.decimal "delivery_fee",                     default: 0.0,   null: false
    t.boolean "auto_generated",                   default: false, null: false
    t.string  "client_name"
    t.string  "client_dba"
    t.string  "client_billing_term"
    t.string  "client_delivery_address_street_1"
    t.string  "client_delivery_address_street_2"
    t.string  "client_delivery_address_city"
    t.string  "client_delivery_address_state"
    t.string  "client_delivery_address_zipcode"
    t.string  "client_billing_address_street_1"
    t.string  "client_billing_address_street_2"
    t.string  "client_billing_address_city"
    t.string  "client_billing_address_state"
    t.string  "client_billing_address_zipcode"
    t.integer "client_billing_term_days"
    t.string  "route_name"
    t.string  "note"
    t.string  "client_primary_contact_name"
    t.string  "client_primary_contact_phone"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "name",                   default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bakery_id"
    t.boolean  "admin",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
