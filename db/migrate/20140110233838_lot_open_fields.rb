class LotOpenFields < ActiveRecord::Migration
  def change
    change_table :lots do |t|
      t.date    :open_date
      t.decimal :open_price, precision: 12, scale: 4
    end

    execute <<-SQL
      UPDATE lots l
         SET open_date  = t.date
           , open_price = t.price
        FROM (SELECT DISTINCT ON (lot_id)
                     lot_id
                   , date
                   , price
                FROM transactions
               ORDER BY lot_id, date) t
       WHERE t.lot_id = l.id
    SQL
  end
end
