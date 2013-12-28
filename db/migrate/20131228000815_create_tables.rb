class CreateTables < ActiveRecord::Migration
  def change
    create_table :investments do |t|
      t.string  :symbol
      t.string  :name
      t.boolean :auto_update

      t.timestamps
    end

    create_table :investment_prices do |t|
      t.integer :investment_id, references: :investments
      t.date    :date
      t.decimal :high,  precision: 12, scale: 4
      t.decimal :low,   precision: 12, scale: 4
      t.decimal :close, precision: 12, scale: 4
      t.float   :adjustment
    end

    create_table :investment_dividends do |t|
      t.integer :price_id, references: :investment_prices
      t.decimal :amount, precision: 12, scale: 4
    end

    create_table :investment_splits do |t|
      t.integer :price_id, references: :investment_prices
      t.integer :before
      t.integer :after
    end
  end
end
