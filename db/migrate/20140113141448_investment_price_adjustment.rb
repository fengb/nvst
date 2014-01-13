class InvestmentPriceAdjustment < ActiveRecord::Migration
  def up
    change_table :investment_historical_prices do |t|
      t.remove :raw_adjustment
      t.float  :adjustment
    end

    change_table :investment_dividends do |t|
      t.rename :date, :ex_date
    end
  end

  def down
    change_table :investment_historical_prices do |t|
      t.rename :ex_date, :date
      t.float  :raw_adjustment
      t.remove :adjustment
    end

    change_table :investment_dividends do |t|
      t.rename :ex_date, :date
    end
  end
end
