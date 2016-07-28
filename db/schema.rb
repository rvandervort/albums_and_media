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

ActiveRecord::Schema.define(version: 20160728143601) do

  create_table "albums", force: :cascade do |t|
    t.string   "name"
    t.integer  "position"
    t.date     "average_date"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "photos_count", default: 0
    t.integer  "videos_count", default: 0
  end

  add_index "albums", ["position"], name: "index_albums_on_position"

  create_table "photos", force: :cascade do |t|
    t.integer  "album_id"
    t.string   "name"
    t.text     "description"
    t.string   "url"
    t.datetime "taken_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "photos", ["album_id"], name: "index_photos_on_album_id"

  create_table "videos", force: :cascade do |t|
    t.integer  "album_id"
    t.string   "name"
    t.text     "description"
    t.string   "url"
    t.datetime "taken_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "videos", ["album_id"], name: "index_videos_on_album_id"

end
