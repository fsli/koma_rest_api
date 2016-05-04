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

ActiveRecord::Schema.define(version: 20160504065016) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string   "company_name",               null: false
    t.integer  "account_status", default: 0, null: false
    t.string   "admin_email"
    t.string   "admin_pass"
    t.string   "company_url"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "devices", force: :cascade do |t|
    t.string   "device_token", null: false
    t.integer  "user_id",      null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "devices", ["device_token"], name: "index_devices_on_device_token", unique: true, using: :btree

  create_table "koma_labels", force: :cascade do |t|
    t.integer  "company_id",  null: false
    t.integer  "label_order", null: false
    t.string   "label_text"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "koma_labels", ["company_id", "label_order"], name: "index_koma_labels_on_company_id_and_label_order", unique: true, using: :btree

  create_table "koma_messages", force: :cascade do |t|
    t.integer  "user_id",                    null: false
    t.integer  "company_id",                 null: false
    t.text     "content"
    t.text     "url"
    t.integer  "oko",            default: 0, null: false
    t.integer  "attr",           default: 0, null: false
    t.integer  "read_by",        default: 0, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "sender_user_id", default: 0, null: false
  end

  create_table "koma_users", force: :cascade do |t|
    t.string   "username"
    t.integer  "attr"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "company_id"
    t.string   "nickname"
    t.string   "picture_url"
    t.string   "facebook_id"
    t.integer  "badge_number", default: 0, null: false
  end

  create_table "komas", force: :cascade do |t|
    t.integer  "owner_id"
    t.datetime "koma_date"
    t.integer  "koma_type"
    t.string   "prospect_name"
    t.text     "memo"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id",                    null: false
    t.text     "message",                    null: false
    t.integer  "badge",                      null: false
    t.boolean  "is_pushed",  default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

end
