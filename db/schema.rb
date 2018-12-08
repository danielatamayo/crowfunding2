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

ActiveRecord::Schema.define(version: 20170502170520) do

  create_table "campaigns", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description",  limit: 65535
    t.boolean  "subscription"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "image"
    t.integer  "goal"
    t.integer  "raised"
    t.boolean  "active",                     default: true
  end

  create_table "charges", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "charge_id"
    t.integer  "amount"
    t.integer  "amount_refunded"
    t.integer  "campaign_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "name"
  end

  create_table "stripe_accounts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "account_type"
    t.integer  "dob_month"
    t.integer  "dob_day"
    t.integer  "dob_year"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "address_city"
    t.string   "address_state"
    t.string   "address_line1"
    t.string   "address_postal"
    t.boolean  "tos"
    t.string   "ssn_last_4"
    t.string   "business_name"
    t.string   "business_tax_id"
    t.string   "personal_id_number"
    t.string   "verification_document"
    t.string   "acct_id"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "organization",           default: "", null: false
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
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "stripe_account"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["organization"], name: "index_users_on_organization", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
