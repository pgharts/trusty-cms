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

ActiveRecord::Schema.define(version: 20161027141250) do

  create_table "config", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "key", limit: 40, default: "", null: false
    t.string "value", default: ""
    t.index ["key"], name: "key", unique: true
  end

  create_table "extension_meta", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.integer "schema_version", default: 0
    t.boolean "enabled", default: true
  end

  create_table "layouts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", limit: 100
    t.text "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.string "content_type", limit: 40
    t.integer "lock_version", default: 0
  end

  create_table "page_fields", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "page_id"
    t.string "name"
    t.string "content"
    t.index ["page_id", "name", "content"], name: "index_page_fields_on_page_id_and_name_and_content"
  end

  create_table "page_parts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", limit: 100
    t.string "filter_id", limit: 25
    t.text "content", limit: 16777215
    t.integer "page_id"
    t.index ["page_id", "name"], name: "parts_by_page"
  end

  create_table "pages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title"
    t.string "slug", limit: 100
    t.string "breadcrumb", limit: 160
    t.string "class_name", limit: 25
    t.integer "status_id", default: 1, null: false
    t.integer "parent_id"
    t.integer "layout_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.boolean "virtual", default: false, null: false
    t.integer "lock_version", default: 0
    t.text "allowed_children_cache"
    t.integer "position"
    t.index ["class_name"], name: "pages_class_name"
    t.index ["parent_id"], name: "pages_parent_id"
    t.index ["slug", "parent_id"], name: "pages_child_slug"
    t.index ["virtual", "status_id"], name: "pages_published"
  end

  create_table "sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "session_id"
    t.text "data"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "snippets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", limit: 100, default: "", null: false
    t.string "filter_id", limit: 25
    t.text "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.integer "lock_version", default: 0
    t.index ["name"], name: "name", unique: true
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", limit: 100
    t.string "email"
    t.string "login", limit: 40, default: "", null: false
    t.string "password", limit: 40
    t.boolean "admin", default: false, null: false
    t.boolean "designer", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.string "salt"
    t.text "notes"
    t.integer "lock_version", default: 0
    t.string "session_token"
    t.string "locale"
    t.string "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.index ["login"], name: "login", unique: true
  end

end
