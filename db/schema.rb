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

ActiveRecord::Schema[7.2].define(version: 2024_01_01_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "instances", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.string "instance_type", null: false
    t.string "family"
    t.integer "vcpus", null: false
    t.float "memory_gb", null: false
    t.decimal "price_per_hour", precision: 10, scale: 6, null: false
    t.string "region", default: "us-east-1", null: false
    t.string "operating_system", default: "Linux"
    t.jsonb "raw_attributes", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["memory_gb"], name: "index_instances_on_memory_gb"
    t.index ["price_per_hour"], name: "index_instances_on_price_per_hour"
    t.index ["provider_id", "instance_type", "region"], name: "index_instances_on_provider_id_and_instance_type_and_region", unique: true
    t.index ["provider_id"], name: "index_instances_on_provider_id"
    t.index ["vcpus"], name: "index_instances_on_vcpus"
  end

  create_table "pricing_imports", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.string "status", default: "pending", null: false
    t.integer "records_imported", default: 0
    t.text "error_message"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_pricing_imports_on_provider_id"
  end

  create_table "providers", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_providers_on_slug", unique: true
  end

  add_foreign_key "instances", "providers"
  add_foreign_key "pricing_imports", "providers"
end
