class TradeSimplication < ActiveRecord::Migration
  def change
    change_table :trades do |t|
      t.integer :cash_id,       references: :investments
      t.decimal :net_amount,    precision: 15, scale: 4
      t.integer :investment_id, references: :investments
      t.decimal :shares,        precision: 15, scale: 4
      t.decimal :price,         precision: 15, scale: 4
    end

    SqlUtil.execute <<-SQL
      UPDATE trades
         SET cash_id       = buy_investment_id
           , net_amount    = buy_shares
           , investment_id = sell_investment_id
           , shares        = -sell_shares
           , price         = sell_price
        FROM investments
       WHERE trades.buy_investment_id = investments.id
         AND type = 'Investment::Cash'
      ;

      UPDATE trades
         SET cash_id       = sell_investment_id
           , net_amount    = -sell_shares
           , investment_id = buy_investment_id
           , shares        = buy_shares
           , price         = buy_price
        FROM investments
       WHERE trades.sell_investment_id = investments.id
         AND type = 'Investment::Cash'
      ;
    SQL

    change_table :trades do |t|
      t.remove :sell_investment_id
      t.remove :sell_shares
      t.remove :sell_price
      t.remove :buy_investment_id
      t.remove :buy_shares
      t.remove :buy_price
    end
  end
end
