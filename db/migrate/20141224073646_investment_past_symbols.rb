class InvestmentPastSymbols < ActiveRecord::Migration
  def change
    change_table :investments do |t|
      t.string :past_symbols, array: true, default: []
    end
  end
end
