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

ActiveRecord::Schema[7.1].define(version: 2026_02_16_060748) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_affecteds", force: :cascade do |t|
    t.string "name"
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_item_affecteds_on_category_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.string "req_no"
    t.string "group"
    t.string "priority"
    t.date "request_date"
    t.string "user_id"
    t.string "user_name"
    t.string "user_location"
    t.string "assigned_group"
    t.string "handler_approver"
    t.text "summary"
    t.integer "age"
    t.string "status"
    t.bigint "category_id"
    t.bigint "item_affected_id"
    t.string "ticket_type"
    t.text "last_comment"
    t.text "resolution_desc"
    t.string "change_type"
    t.string "risk_level"
    t.date "change_date"
    t.date "modified_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_tickets_on_category_id"
    t.index ["item_affected_id"], name: "index_tickets_on_item_affected_id"
    t.index ["req_no"], name: "index_tickets_on_req_no", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "item_affecteds", "categories"
  add_foreign_key "tickets", "categories"
  add_foreign_key "tickets", "item_affecteds"
end
