class UniqueIndexes < ActiveRecord::Migration
  def change
    add_index :investment_historical_prices, [:investment_id, :date], unique: true
    add_index :investment_dividends, [:investment_id, :ex_date], unique: true
    add_index :investment_splits, [:investment_id, :date], unique: true
  end
end
