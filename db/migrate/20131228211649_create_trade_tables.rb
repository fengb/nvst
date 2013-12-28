class CreateTradeTables < ActiveRecord::Migration
  def change
    create_table :contributions do |t|
      t.integer :user_id, references: :users
      t.date    :date
      t.decimal :amount, precision: 18, scale: 4

      t.timestamps
    end

    create_table :trades do |t|
      t.date    :date

      t.integer :sell_investment_id, references: :investments
      t.decimal :sell_shares, precision: 15, scale: 4
      t.decimal :sell_price,  precision: 12, scale: 4

      t.integer :buy_investment_id, references: :investments
      t.decimal :buy_shares, precision: 15, scale: 4
      t.decimal :buy_price,  precision: 12, scale: 4

      t.timestamps
    end

    create_table :events do |t|
      t.integer :src_investment_id, references: :investments
      t.date    :date
      t.decimal :amount, precision: 12, scale: 4
      t.string  :reason

      t.timestamps
    end

    create_table :expenses do |t|
      t.date    :date
      t.decimal :amount, precision: 12, scale: 4
      t.string  :vendor
      t.string  :memo

      t.timestamps
    end
  end
end
