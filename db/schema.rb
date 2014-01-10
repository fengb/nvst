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

ActiveRecord::Schema.define(version: 20140110233838) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: true do |t|
    t.string   "username",                        null: false
    t.string   "encrypted_password",              null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                              null: false
    t.string   "encrypted_password",                 null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ownerships", force: true do |t|
    t.integer  "user_id"
    t.date     "date"
    t.decimal  "units",      precision: 18, scale: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], :name => "fk__ownerships_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_ownerships_user_id"
  end

  create_table "contributions", force: true do |t|
    t.integer  "user_id"
    t.date     "date"
    t.decimal  "amount",       precision: 18, scale: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ownership_id"
    t.index ["ownership_id"], :name => "fk__contributions_ownership_id"
    t.index ["user_id"], :name => "fk__contributions_user_id"
    t.foreign_key ["ownership_id"], "ownerships", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_contributions_ownership_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_contributions_user_id"
  end

  create_table "investments", force: true do |t|
    t.string   "symbol"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category"
  end

  create_table "lots", force: true do |t|
    t.integer "investment_id"
    t.date    "open_date"
    t.decimal "open_price",    precision: 12, scale: 4
    t.index ["investment_id"], :name => "fk__lots_investment_id"
    t.foreign_key ["investment_id"], "investments", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_lots_investment_id"
  end

  create_table "transactions", force: true do |t|
    t.integer "lot_id"
    t.date    "date"
    t.decimal "shares", precision: 15, scale: 4
    t.decimal "price",  precision: 12, scale: 4
    t.index ["lot_id"], :name => "fk__transactions_lot_id"
    t.foreign_key ["lot_id"], "lots", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_transactions_lot_id"
  end

  create_table "contributions_transactions", force: true do |t|
    t.integer "contribution_id"
    t.integer "transaction_id"
    t.index ["contribution_id"], :name => "index_contributions_transactions_on_contribution_id"
    t.index ["transaction_id"], :name => "index_contributions_transactions_on_transaction_id", :unique => true
    t.foreign_key ["contribution_id"], "contributions", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_contributions_transactions_contribution_id"
    t.foreign_key ["transaction_id"], "transactions", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_contributions_transactions_transaction_id"
  end

  create_table "events", force: true do |t|
    t.integer  "src_investment_id"
    t.date     "date"
    t.decimal  "amount",            precision: 12, scale: 4
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["src_investment_id"], :name => "fk__events_src_investment_id"
    t.foreign_key ["src_investment_id"], "investments", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_events_src_investment_id"
  end

  create_table "events_transactions", force: true do |t|
    t.integer "event_id"
    t.integer "transaction_id"
    t.index ["event_id"], :name => "index_events_transactions_on_event_id"
    t.index ["transaction_id"], :name => "index_events_transactions_on_transaction_id", :unique => true
    t.foreign_key ["event_id"], "events", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_events_transactions_event_id"
    t.foreign_key ["transaction_id"], "transactions", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_events_transactions_transaction_id"
  end

  create_table "expenses", force: true do |t|
    t.date     "date"
    t.decimal  "amount",     precision: 12, scale: 4
    t.string   "vendor"
    t.string   "memo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category"
  end

  create_table "expenses_transactions", force: true do |t|
    t.integer "expense_id"
    t.integer "transaction_id"
    t.index ["expense_id"], :name => "index_expenses_transactions_on_expense_id"
    t.index ["transaction_id"], :name => "index_expenses_transactions_on_transaction_id", :unique => true
    t.foreign_key ["expense_id"], "expenses", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_expenses_transactions_expense_id"
    t.foreign_key ["transaction_id"], "transactions", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_expenses_transactions_transaction_id"
  end

  create_table "investment_dividends", force: true do |t|
    t.integer "investment_id"
    t.date    "date"
    t.decimal "amount",        precision: 12, scale: 4
    t.index ["date"], :name => "index_investment_dividends_on_date"
    t.index ["investment_id"], :name => "fk__investment_dividends_investment_id"
    t.foreign_key ["investment_id"], "investments", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_investment_dividends_investment_id"
  end

  create_table "investment_historical_prices", force: true do |t|
    t.integer "investment_id"
    t.date    "date"
    t.decimal "high",           precision: 12, scale: 4
    t.decimal "low",            precision: 12, scale: 4
    t.decimal "close",          precision: 12, scale: 4
    t.float   "raw_adjustment"
    t.index ["date"], :name => "index_investment_historical_prices_on_date"
    t.index ["investment_id"], :name => "fk__investment_historical_prices_investment_id"
    t.foreign_key ["investment_id"], "investments", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_investment_historical_prices_investment_id"
  end

  create_table "investment_splits", force: true do |t|
    t.integer "investment_id"
    t.date    "date"
    t.integer "before"
    t.integer "after"
    t.index ["date"], :name => "index_investment_splits_on_date"
    t.index ["investment_id"], :name => "fk__investment_splits_investment_id"
    t.foreign_key ["investment_id"], "investments", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_investment_splits_investment_id"
  end

  create_table "rails_admin_histories", force: true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["item", "table", "month", "year"], :name => "index_rails_admin_histories"
  end

  create_table "trades", force: true do |t|
    t.date     "date"
    t.integer  "sell_investment_id"
    t.decimal  "sell_shares",        precision: 15, scale: 4
    t.decimal  "sell_price",         precision: 12, scale: 4
    t.integer  "buy_investment_id"
    t.decimal  "buy_shares",         precision: 15, scale: 4
    t.decimal  "buy_price",          precision: 12, scale: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["buy_investment_id"], :name => "fk__trades_buy_investment_id"
    t.index ["sell_investment_id"], :name => "fk__trades_sell_investment_id"
    t.foreign_key ["buy_investment_id"], "investments", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_trades_buy_investment_id"
    t.foreign_key ["sell_investment_id"], "investments", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_trades_sell_investment_id"
  end

  create_table "trades_transactions", force: true do |t|
    t.integer "trade_id"
    t.integer "transaction_id"
    t.index ["trade_id"], :name => "index_trades_transactions_on_trade_id"
    t.index ["transaction_id"], :name => "index_trades_transactions_on_transaction_id", :unique => true
    t.foreign_key ["trade_id"], "trades", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_trades_transactions_trade_id"
    t.foreign_key ["transaction_id"], "transactions", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_trades_transactions_transaction_id"
  end

  create_table "transfers", force: true do |t|
    t.date    "date"
    t.decimal "amount",            precision: 21, scale: 8
    t.integer "from_user_id"
    t.integer "to_user_id"
    t.integer "from_ownership_id"
    t.integer "to_ownership_id"
    t.index ["from_ownership_id"], :name => "fk__transfers_from_ownership_id"
    t.index ["from_user_id"], :name => "fk__transfers_from_user_id"
    t.index ["to_ownership_id"], :name => "fk__transfers_to_ownership_id"
    t.index ["to_user_id"], :name => "fk__transfers_to_user_id"
    t.foreign_key ["from_ownership_id"], "ownerships", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_transfers_from_ownership_id"
    t.foreign_key ["from_user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_transfers_from_user_id"
    t.foreign_key ["to_ownership_id"], "ownerships", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_transfers_to_ownership_id"
    t.foreign_key ["to_user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_transfers_to_user_id"
  end

end
