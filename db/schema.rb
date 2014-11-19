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

ActiveRecord::Schema.define(version: 20141119185915) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ingredients", force: true do |t|
    t.string   "name"
    t.decimal  "price"
    t.decimal  "measure"
    t.integer  "unit"
    t.integer  "ingredient_type"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ingredients", ["name"], name: "index_ingredients_on_name", unique: true, using: :btree

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
  end

  add_index "recipes", ["name"], name: "index_recipes_on_name", unique: true, using: :btree

end
