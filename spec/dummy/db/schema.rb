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

ActiveRecord::Schema.define(version: 20120209231801) do

  create_table "config", force: :cascade do |t|
    t.string "key",   limit: 40,  default: "", null: false
    t.string "value", limit: 255, default: ""
  end

  add_index "config", ["key"], name: "key", unique: true, using: :btree

  create_table "extension_meta", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "schema_version", limit: 4,   default: 0
    t.boolean "enabled",                    default: true
  end

  create_table "layouts", force: :cascade do |t|
    t.string   "name",          limit: 100
    t.text     "content",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id", limit: 4
    t.integer  "updated_by_id", limit: 4
    t.string   "content_type",  limit: 40
    t.integer  "lock_version",  limit: 4,     default: 0
  end

  create_table "page_fields", force: :cascade do |t|
    t.integer "page_id", limit: 4
    t.string  "name",    limit: 255
    t.string  "content", limit: 255
  end

  add_index "page_fields", ["page_id", "name", "content"], name: "index_page_fields_on_page_id_and_name_and_content", using: :btree

  create_table "page_parts", force: :cascade do |t|
    t.string  "name",      limit: 100
    t.string  "filter_id", limit: 25
    t.text    "content",   limit: 16777215
    t.integer "page_id",   limit: 4
  end

  add_index "page_parts", ["page_id", "name"], name: "parts_by_page", using: :btree

  create_table "pages", force: :cascade do |t|
    t.string   "title",                  limit: 255
    t.string   "slug",                   limit: 100
    t.string   "breadcrumb",             limit: 160
    t.string   "class_name",             limit: 25
    t.integer  "status_id",              limit: 4,     default: 1,     null: false
    t.integer  "parent_id",              limit: 4
    t.integer  "layout_id",              limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.integer  "created_by_id",          limit: 4
    t.integer  "updated_by_id",          limit: 4
    t.boolean  "virtual",                              default: false, null: false
    t.integer  "lock_version",           limit: 4,     default: 0
    t.text     "allowed_children_cache", limit: 65535
  end

  add_index "pages", ["class_name"], name: "pages_class_name", using: :btree
  add_index "pages", ["parent_id"], name: "pages_parent_id", using: :btree
  add_index "pages", ["slug", "parent_id"], name: "pages_child_slug", using: :btree
  add_index "pages", ["virtual", "status_id"], name: "pages_published", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255
    t.text     "data",       limit: 65535
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "snippets", force: :cascade do |t|
    t.string   "name",          limit: 100,   default: "", null: false
    t.string   "filter_id",     limit: 25
    t.text     "content",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id", limit: 4
    t.integer  "updated_by_id", limit: 4
    t.integer  "lock_version",  limit: 4,     default: 0
  end

  add_index "snippets", ["name"], name: "name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",          limit: 100
    t.string   "email",         limit: 255
    t.string   "login",         limit: 40,    default: "",    null: false
    t.string   "password",      limit: 40
    t.boolean  "admin",                       default: false, null: false
    t.boolean  "designer",                    default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id", limit: 4
    t.integer  "updated_by_id", limit: 4
    t.string   "salt",          limit: 255
    t.text     "notes",         limit: 65535
    t.integer  "lock_version",  limit: 4,     default: 0
    t.string   "session_token", limit: 255
    t.string   "locale",        limit: 255
  end

  add_index "users", ["login"], name: "login", unique: true, using: :btree

end
