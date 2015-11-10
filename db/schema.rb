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

ActiveRecord::Schema.define(version: 20151013185308) do

  create_table "cameras", force: :cascade do |t|
    t.string   "name"
    t.boolean  "lens_profile", default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "mapping_methods", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "maps", force: :cascade do |t|
    t.string   "title"
    t.string   "image_uid"
    t.string   "thumbnail_uid"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "bearing"
    t.string   "camera"
    t.string   "mapping_method_id"
    t.string   "taken_at"
    t.string   "user_id"
    t.integer  "status"
    t.boolean  "failed"
    t.boolean  "queued",            default: false
    t.datetime "queued_at"
    t.boolean  "processing",        default: false
    t.datetime "generated_at"
    t.boolean  "complete",          default: false
    t.boolean  "public",            default: false
    t.boolean  "gallery",           default: false
    t.boolean  "public_gps",        default: false
    t.boolean  "gallery_gps",       default: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "photos", force: :cascade do |t|
    t.string   "image_uid"
    t.string   "user_id"
    t.string   "image_name"
    t.integer  "map_id"
    t.string   "camera"
    t.float    "gps_latitude"
    t.float    "gps_longitude"
    t.string   "taken_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "location"
    t.string   "image_url"
    t.string   "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
