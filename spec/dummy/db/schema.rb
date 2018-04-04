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

ActiveRecord::Schema.define(version: 2016_10_27_141250) do

  create_table "assets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "caption"
    t.string "title"
    t.string "asset_file_name"
    t.string "asset_content_type"
    t.integer "asset_file_size"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "uuid"
    t.integer "original_width"
    t.integer "original_height"
    t.string "original_extension"
  end

  create_table "config", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key", limit: 40, default: "", null: false
    t.string "value", default: ""
    t.index ["key"], name: "key", unique: true
  end

  create_table "extension_meta", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "schema_version", default: 0
    t.boolean "enabled", default: true
  end

  create_table "layouts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 100
    t.text "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.string "content_type", limit: 40
    t.integer "lock_version", default: 0
    t.integer "site_id"
  end

  create_table "page_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_id"
    t.integer "page_id"
    t.integer "position"
  end

  create_table "page_fields", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "page_id"
    t.string "name"
    t.string "content"
    t.index ["page_id", "name", "content"], name: "index_page_fields_on_page_id_and_name_and_content"
  end

  create_table "page_parts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 100
    t.string "filter_id", limit: 25
    t.text "content", limit: 16777215
    t.integer "page_id"
    t.index ["page_id", "name"], name: "parts_by_page"
  end

  create_table "pages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
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
    t.integer "site_id"
    t.text "allowed_children_cache"
    t.integer "position"
    t.index ["class_name"], name: "pages_class_name"
    t.index ["parent_id"], name: "pages_parent_id"
    t.index ["site_id"], name: "index_pages_on_site_id"
    t.index ["slug", "parent_id"], name: "pages_child_slug"
    t.index ["virtual", "status_id"], name: "pages_published"
  end

  create_table "sessions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "session_id"
    t.text "data"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "sites", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "domain"
    t.integer "homepage_id"
    t.integer "position", default: 0
    t.integer "created_by_id"
    t.datetime "created_at"
    t.integer "updated_by_id"
    t.datetime "updated_at"
    t.string "subtitle"
    t.string "abbreviation"
    t.string "base_domain"
  end

  create_table "snippets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 100, default: "", null: false
    t.string "filter_id", limit: 25
    t.text "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.integer "lock_version", default: 0
    t.integer "site_id"
    t.index ["name", "site_id"], name: "name_site_id", unique: true
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
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
    t.integer "site_id"
    t.string "locale"
    t.string "password_reset_token"
    t.datetime "password_reset_sent_at"
  end

end
