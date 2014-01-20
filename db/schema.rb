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

ActiveRecord::Schema.define(version: 20140120210851) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: true do |t|
    t.string   "name",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "chatroom_url"
  end

  add_index "companies", ["name"], name: "index_companies_on_name", unique: true, using: :btree

  create_table "reports", force: true do |t|
    t.integer  "company_id",                       null: false
    t.integer  "test_suite_id",                    null: false
    t.datetime "initiated_at"
    t.integer  "initiated_by"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.integer  "monitored_by"
    t.string   "status",        default: "queued", null: false
    t.text     "summary"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test_cases", force: true do |t|
    t.integer  "company_id",                      null: false
    t.integer  "test_suite_id",                   null: false
    t.string   "title",              default: "", null: false
    t.text     "description",        default: "", null: false
    t.datetime "setup_started_at"
    t.datetime "setup_completed_at"
    t.string   "pending_message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
  end

  create_table "test_results", force: true do |t|
    t.integer  "report_id"
    t.integer  "test_case_id"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.string   "status"
    t.text     "summary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "execution_time"
  end

  create_table "test_suites", force: true do |t|
    t.integer  "company_id",                   null: false
    t.string   "title",           default: "", null: false
    t.string   "description",     default: "", null: false
    t.string   "setup_video_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                                null: false
    t.integer  "company_id",                          null: false
  end

  add_index "users", ["company_id"], name: "index_users_on_company_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
