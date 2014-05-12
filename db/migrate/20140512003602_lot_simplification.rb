class LotSimplification < ActiveRecord::Migration
  def change
    change_table :transactions do |t|
      t.boolean :is_opening
    end

    change_table :lots do |t|
      t.remove :open_date
      t.remove :open_price
    end

    drop_table :adjustments_lots

    execute 'TRUNCATE lots RESTART IDENTITY CASCADE'
  end
end
