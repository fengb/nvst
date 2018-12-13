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

ActiveRecord::Schema.define(version: 20181213042711) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.integer "position_id"
    t.date    "date"
    t.decimal "shares",      precision: 15, scale: 4
    t.decimal "price",       precision: 12, scale: 4
    t.boolean "is_opening",                           default: false
    t.date    "tax_date"
    t.string  "source_type",                                          null: false
    t.integer "source_id",                                            null: false
    t.index ["position_id"], name: "fk__activities_lot_id", using: :btree
    t.index ["source_type", "source_id"], name: "index_activities_on_source_type_and_source_id", using: :btree
  end

  create_table "activities_activity_adjustments", force: :cascade do |t|
    t.integer "activity_id"
    t.integer "activity_adjustment_id"
    t.index ["activity_adjustment_id"], name: "fk__transaction_adjustments_transactions_adjustment_id", using: :btree
    t.index ["activity_id"], name: "fk__activities_activity_adjustments_transaction_id", using: :btree
  end

  create_table "activity_adjustments", force: :cascade do |t|
    t.date    "date"
    t.integer "numerator"
    t.integer "denominator"
    t.string  "reason",      limit: 255
    t.string  "source_type",             null: false
    t.integer "source_id",               null: false
    t.index ["source_type", "source_id"], name: "index_activity_adjustments_on_source_type_and_source_id", using: :btree
  end

  create_table "admins", force: :cascade do |t|
    t.string   "username",            limit: 255,             null: false
    t.string   "encrypted_password",  limit: 255,             null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                   default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",  limit: 255
    t.string   "last_sign_in_ip",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contributions", force: :cascade do |t|
    t.integer  "user_id"
    t.date     "date"
    t.decimal  "amount",     precision: 18, scale: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "fk__contributions_user_id", using: :btree
  end

  create_table "contributions_ownerships", force: :cascade do |t|
    t.integer "contribution_id"
    t.integer "ownership_id"
    t.index ["contribution_id"], name: "fk__contributions_ownerships_contribution_id", using: :btree
    t.index ["ownership_id"], name: "fk__contributions_ownerships_ownership_id", using: :btree
  end

  create_table "events", force: :cascade do |t|
    t.integer  "src_investment_id"
    t.date     "date"
    t.decimal  "amount",                        precision: 12, scale: 4
    t.string   "category",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["src_investment_id"], name: "fk__events_src_investment_id", using: :btree
  end

  create_table "expenses", force: :cascade do |t|
    t.date     "date"
    t.decimal  "amount",                               precision: 12, scale: 4
    t.string   "vendor",                   limit: 255
    t.string   "memo",                     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category",                 limit: 255
    t.integer  "reinvestment_for_user_id"
    t.index ["reinvestment_for_user_id"], name: "fk__expenses_reinvestment_for_user_id", using: :btree
  end

  create_table "expenses_ownerships", force: :cascade do |t|
    t.integer "expense_id"
    t.integer "ownership_id"
    t.index ["expense_id"], name: "fk__expenses_ownerships_expense_id", using: :btree
    t.index ["ownership_id"], name: "fk__expenses_ownerships_ownership_id", using: :btree
  end

  create_table "expirations", force: :cascade do |t|
    t.integer  "investment_id"
    t.date     "date"
    t.decimal  "shares",        precision: 15, scale: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["investment_id"], name: "fk__expirations_investment_id", using: :btree
  end

  create_table "investment_dividends", force: :cascade do |t|
    t.integer "investment_id"
    t.date    "ex_date"
    t.decimal "amount",        precision: 12, scale: 4
    t.index ["ex_date"], name: "index_investment_dividends_on_ex_date", using: :btree
    t.index ["investment_id", "ex_date"], name: "index_investment_dividends_on_investment_id_and_ex_date", unique: true, using: :btree
    t.index ["investment_id"], name: "fk__investment_dividends_investment_id", using: :btree
  end

  create_table "investment_historical_prices", force: :cascade do |t|
    t.integer "investment_id"
    t.date    "date"
    t.decimal "high",          precision: 12, scale: 4
    t.decimal "low",           precision: 12, scale: 4
    t.decimal "close",         precision: 12, scale: 4
    t.float   "adjustment"
    t.index ["date"], name: "index_investment_historical_prices_on_date", using: :btree
    t.index ["investment_id", "date"], name: "index_investment_historical_prices_on_investment_id_and_date", unique: true, using: :btree
    t.index ["investment_id"], name: "fk__investment_historical_prices_investment_id", using: :btree
  end

  create_table "investment_splits", force: :cascade do |t|
    t.integer "investment_id"
    t.date    "date"
    t.integer "before"
    t.integer "after"
    t.index ["date"], name: "index_investment_splits_on_date", using: :btree
    t.index ["investment_id", "date"], name: "index_investment_splits_on_investment_id_and_date", unique: true, using: :btree
    t.index ["investment_id"], name: "fk__investment_splits_investment_id", using: :btree
  end

  create_table "investments", force: :cascade do |t|
    t.string   "symbol",       limit: 255
    t.string   "name",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",         limit: 255
    t.string   "past_symbols",             default: [], array: true
  end

  create_table "ownerships", force: :cascade do |t|
    t.integer  "user_id"
    t.date     "date"
    t.decimal  "units",      precision: 18, scale: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "fk__ownerships_user_id", using: :btree
  end

  create_table "ownerships_transfers", force: :cascade do |t|
    t.integer "ownership_id"
    t.integer "transfer_id"
    t.index ["ownership_id"], name: "fk__ownerships_transfers_ownership_id", using: :btree
    t.index ["transfer_id"], name: "fk__fees_ownerships_transfer_id", using: :btree
  end

  create_table "positions", force: :cascade do |t|
    t.integer "investment_id"
    t.index ["investment_id"], name: "fk__positions_investment_id", using: :btree
  end

  create_table "rails_admin_histories", force: :cascade do |t|
    t.text     "message"
    t.string   "username",   limit: 255
    t.integer  "item"
    t.string   "table",      limit: 255
    t.integer  "month",      limit: 2
    t.bigint   "year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["item", "table", "month", "year"], name: "index_rails_admin_histories", using: :btree
  end

  create_table "trades", force: :cascade do |t|
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cash_id"
    t.decimal  "net_amount",    precision: 15, scale: 4
    t.integer  "investment_id"
    t.decimal  "shares",        precision: 15, scale: 4
    t.decimal  "price",         precision: 15, scale: 4
    t.index ["cash_id"], name: "fk__trades_cash_id", using: :btree
    t.index ["investment_id"], name: "fk__trades_investment_id", using: :btree
  end

  create_table "transfers", force: :cascade do |t|
    t.date     "date"
    t.decimal  "amount",       precision: 21, scale: 8
    t.integer  "from_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "to_user_id"
    t.index ["from_user_id"], name: "fk__transfers_from_user_id", using: :btree
    t.index ["to_user_id"], name: "fk__transfers_to_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255,                 null: false
    t.string   "encrypted_password",     limit: 255,                 null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_fee_collector",                   default: false
  end

  add_foreign_key "activities", "positions", name: "fk_activities_lot_id"
  add_foreign_key "activities_activity_adjustments", "activities", name: "fk_activities_activity_adjustments_transaction_id"
  add_foreign_key "activities_activity_adjustments", "activity_adjustments", name: "fk_activities_activity_adjustments_adjustment_id"
  add_foreign_key "contributions", "users", name: "fk_contributions_user_id"
  add_foreign_key "contributions_ownerships", "contributions", name: "fk_contributions_ownerships_contribution_id"
  add_foreign_key "contributions_ownerships", "ownerships", name: "fk_contributions_ownerships_ownership_id"
  add_foreign_key "events", "investments", column: "src_investment_id", name: "fk_events_src_investment_id"
  add_foreign_key "expenses", "users", column: "reinvestment_for_user_id", name: "fk_expenses_reinvestment_for_user_id"
  add_foreign_key "expenses_ownerships", "expenses", name: "fk_expenses_ownerships_expense_id"
  add_foreign_key "expenses_ownerships", "ownerships", name: "fk_expenses_ownerships_ownership_id"
  add_foreign_key "expirations", "investments", name: "fk_expirations_investment_id"
  add_foreign_key "investment_dividends", "investments", name: "fk_investment_dividends_investment_id"
  add_foreign_key "investment_historical_prices", "investments", name: "fk_investment_historical_prices_investment_id"
  add_foreign_key "investment_splits", "investments", name: "fk_investment_splits_investment_id"
  add_foreign_key "ownerships", "users", name: "fk_ownerships_user_id"
  add_foreign_key "ownerships_transfers", "ownerships", name: "fk_ownerships_transfers_ownership_id"
  add_foreign_key "ownerships_transfers", "transfers", name: "fk_ownerships_transfers_transfer_id"
  add_foreign_key "positions", "investments", name: "fk_positions_investment_id"
  add_foreign_key "trades", "investments", column: "cash_id", name: "fk_trades_cash_id"
  add_foreign_key "trades", "investments", name: "fk_trades_investment_id"
  add_foreign_key "transfers", "users", column: "from_user_id", name: "fk_transfers_from_user_id"
  add_foreign_key "transfers", "users", column: "to_user_id", name: "fk_transfers_to_user_id"
end
