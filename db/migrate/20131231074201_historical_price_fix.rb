class HistoricalPriceFix < ActiveRecord::Migration
  def change
    rename_table :investment_prices, :investment_historical_prices
    rename_column :investment_historical_prices, :adjustment, :raw_adjustment
  end
end
