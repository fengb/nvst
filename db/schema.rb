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

ActiveRecord::Schema.define(version: 20141228031403) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.integer "position_id"
    t.date    "date"
    t.decimal "shares",      precision: 15, scale: 4
    t.decimal "price",       precision: 12, scale: 4
    t.boolean "is_opening",                           default: false
    t.date    "tax_date"
  end

  add_index "activities", ["position_id"], name: "fk__activities_lot_id", using: :btree

  create_table "activities_activity_adjustments", force: :cascade do |t|
    t.integer "activity_id"
    t.integer "activity_adjustment_id"
  end

  add_index "activities_activity_adjustments", ["activity_adjustment_id"], name: "fk__transaction_adjustments_transactions_adjustment_id", using: :btree
  add_index "activities_activity_adjustments", ["activity_id"], name: "fk__activities_activity_adjustments_transaction_id", using: :btree

  create_table "activities_contributions", force: :cascade do |t|
    t.integer "contribution_id"
    t.integer "activity_id"
  end

  add_index "activities_contributions", ["activity_id"], name: "index_activities_contributions_on_activity_id", unique: true, using: :btree
  add_index "activities_contributions", ["contribution_id"], name: "index_activities_contributions_on_contribution_id", using: :btree

  create_table "activities_events", force: :cascade do |t|
    t.integer "event_id"
    t.integer "activity_id"
  end

  add_index "activities_events", ["activity_id"], name: "index_activities_events_on_activity_id", unique: true, using: :btree
  add_index "activities_events", ["event_id"], name: "index_activities_events_on_event_id", using: :btree

  create_table "activities_expenses", force: :cascade do |t|
    t.integer "expense_id"
    t.integer "activity_id"
  end

  add_index "activities_expenses", ["activity_id"], name: "index_activities_expenses_on_activity_id", unique: true, using: :btree
  add_index "activities_expenses", ["expense_id"], name: "index_activities_expenses_on_expense_id", using: :btree

  create_table "activities_expirations", force: :cascade do |t|
    t.integer "activity_id"
    t.integer "expiration_id"
  end

  add_index "activities_expirations", ["activity_id"], name: "fk__activities_expirations_activity_id", using: :btree
  add_index "activities_expirations", ["expiration_id"], name: "fk__activities_expirations_expiration_id", using: :btree

  create_table "activities_trades", force: :cascade do |t|
    t.integer "trade_id"
    t.integer "activity_id"
  end

  add_index "activities_trades", ["activity_id"], name: "index_activities_trades_on_activity_id", unique: true, using: :btree
  add_index "activities_trades", ["trade_id"], name: "index_activities_trades_on_trade_id", using: :btree

  create_table "activity_adjustments", force: :cascade do |t|
    t.date    "date"
    t.integer "numerator"
    t.integer "denominator"
    t.string  "reason",      limit: 255
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
  end

  add_index "contributions", ["user_id"], name: "fk__contributions_user_id", using: :btree

  create_table "contributions_ownerships", force: :cascade do |t|
    t.integer "contribution_id"
    t.integer "ownership_id"
  end

  add_index "contributions_ownerships", ["contribution_id"], name: "fk__contributions_ownerships_contribution_id", using: :btree
  add_index "contributions_ownerships", ["ownership_id"], name: "fk__contributions_ownerships_ownership_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.integer  "src_investment_id"
    t.date     "date"
    t.decimal  "amount",                        precision: 12, scale: 4
    t.string   "category",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["src_investment_id"], name: "fk__events_src_investment_id", using: :btree

  create_table "expenses", force: :cascade do |t|
    t.date     "date"
    t.decimal  "amount",                               precision: 12, scale: 4
    t.string   "vendor",                   limit: 255
    t.string   "memo",                     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category",                 limit: 255
    t.integer  "reinvestment_for_user_id"
  end

  add_index "expenses", ["reinvestment_for_user_id"], name: "fk__expenses_reinvestment_for_user_id", using: :btree

  create_table "expenses_ownerships", force: :cascade do |t|
    t.integer "expense_id"
    t.integer "ownership_id"
  end

  add_index "expenses_ownerships", ["expense_id"], name: "fk__expenses_ownerships_expense_id", using: :btree
  add_index "expenses_ownerships", ["ownership_id"], name: "fk__expenses_ownerships_ownership_id", using: :btree

  create_table "expirations", force: :cascade do |t|
    t.integer  "investment_id"
    t.date     "date"
    t.decimal  "shares",        precision: 15, scale: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "expirations", ["investment_id"], name: "fk__expirations_investment_id", using: :btree

  create_table "investment_dividends", force: :cascade do |t|
    t.integer "investment_id"
    t.date    "ex_date"
    t.decimal "amount",        precision: 12, scale: 4
  end

  add_index "investment_dividends", ["ex_date"], name: "index_investment_dividends_on_ex_date", using: :btree
  add_index "investment_dividends", ["investment_id", "ex_date"], name: "index_investment_dividends_on_investment_id_and_ex_date", unique: true, using: :btree
  add_index "investment_dividends", ["investment_id"], name: "fk__investment_dividends_investment_id", using: :btree

  create_table "investment_historical_prices", force: :cascade do |t|
    t.integer "investment_id"
    t.date    "date"
    t.decimal "high",          precision: 12, scale: 4
    t.decimal "low",           precision: 12, scale: 4
    t.decimal "close",         precision: 12, scale: 4
    t.float   "adjustment"
  end

  add_index "investment_historical_prices", ["date"], name: "index_investment_historical_prices_on_date", using: :btree
  add_index "investment_historical_prices", ["investment_id", "date"], name: "index_investment_historical_prices_on_investment_id_and_date", unique: true, using: :btree
  add_index "investment_historical_prices", ["investment_id"], name: "fk__investment_historical_prices_investment_id", using: :btree

  create_table "investment_splits", force: :cascade do |t|
    t.integer "investment_id"
    t.date    "date"
    t.integer "before"
    t.integer "after"
    t.integer "activity_adjustment_id"
  end

  add_index "investment_splits", ["activity_adjustment_id"], name: "fk__investment_splits_transaction_adjustment_id", using: :btree
  add_index "investment_splits", ["date"], name: "index_investment_splits_on_date", using: :btree
  add_index "investment_splits", ["investment_id", "date"], name: "index_investment_splits_on_investment_id_and_date", unique: true, using: :btree
  add_index "investment_splits", ["investment_id"], name: "fk__investment_splits_investment_id", using: :btree

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
  end

  add_index "ownerships", ["user_id"], name: "fk__ownerships_user_id", using: :btree

  create_table "ownerships_transfers", force: :cascade do |t|
    t.integer "ownership_id"
    t.integer "transfer_id"
  end

  add_index "ownerships_transfers", ["ownership_id"], name: "fk__ownerships_transfers_ownership_id", using: :btree
  add_index "ownerships_transfers", ["transfer_id"], name: "fk__fees_ownerships_transfer_id", using: :btree

  create_table "positions", force: :cascade do |t|
    t.integer "investment_id"
  end

  add_index "positions", ["investment_id"], name: "fk__positions_investment_id", using: :btree

  create_table "rails_admin_histories", force: :cascade do |t|
    t.text     "message"
    t.string   "username",   limit: 255
    t.integer  "item"
    t.string   "table",      limit: 255
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories", using: :btree

  create_table "trades", force: :cascade do |t|
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cash_id"
    t.decimal  "net_amount",    precision: 15, scale: 4
    t.integer  "investment_id"
    t.decimal  "shares",        precision: 15, scale: 4
    t.decimal  "price",         precision: 15, scale: 4
  end

  add_index "trades", ["cash_id"], name: "fk__trades_cash_id", using: :btree
  add_index "trades", ["investment_id"], name: "fk__trades_investment_id", using: :btree

  create_table "transfers", force: :cascade do |t|
    t.date     "date"
    t.decimal  "amount",       precision: 21, scale: 8
    t.integer  "from_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "to_user_id"
  end

  add_index "transfers", ["from_user_id"], name: "fk__transfers_from_user_id", using: :btree
  add_index "transfers", ["to_user_id"], name: "fk__transfers_to_user_id", using: :btree

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
  add_foreign_key "activities_contributions", "activities", name: "fk_activities_contributions_transaction_id"
  add_foreign_key "activities_contributions", "contributions", name: "fk_activities_contributions_contribution_id"
  add_foreign_key "activities_events", "activities", name: "fk_activities_events_transaction_id"
  add_foreign_key "activities_events", "events", name: "fk_activities_events_event_id"
  add_foreign_key "activities_expenses", "activities", name: "fk_activities_expenses_transaction_id"
  add_foreign_key "activities_expenses", "expenses", name: "fk_activities_expenses_expense_id"
  add_foreign_key "activities_expirations", "activities", name: "fk_activities_expirations_activity_id"
  add_foreign_key "activities_expirations", "expirations", name: "fk_activities_expirations_expiration_id"
  add_foreign_key "activities_trades", "activities", name: "fk_activities_trades_transaction_id"
  add_foreign_key "activities_trades", "trades", name: "fk_activities_trades_trade_id"
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
  add_foreign_key "investment_splits", "activity_adjustments", name: "fk_investment_splits_transaction_adjustment_id"
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
