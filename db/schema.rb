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

ActiveRecord::Schema.define(version: 20131228000815) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "investments", force: true do |t|
    t.string   "symbol"
    t.string   "name"
    t.boolean  "auto_update"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "investment_dividends", force: true do |t|
    t.integer "investment_id"
    t.date    "date"
    t.decimal "amount",        precision: 12, scale: 4
    t.index ["date"], :name => "index_investment_dividends_on_date"
    t.index ["investment_id"], :name => "fk__investment_dividends_investment_id"
    t.foreign_key ["investment_id"], "investments", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_investment_dividends_investment_id"
  end

  create_table "investment_prices", force: true do |t|
    t.integer "investment_id"
    t.date    "date"
    t.decimal "high",          precision: 12, scale: 4
    t.decimal "low",           precision: 12, scale: 4
    t.decimal "close",         precision: 12, scale: 4
    t.float   "adjustment"
    t.index ["date"], :name => "index_investment_prices_on_date"
    t.index ["investment_id"], :name => "fk__investment_prices_investment_id"
    t.foreign_key ["investment_id"], "investments", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_investment_prices_investment_id"
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

end
