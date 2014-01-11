class TransactionDecimal < ActiveRecord::Migration
  def up
    change_column :transactions, :price, :decimal, precision: 18, scale: 10
    change_column :lots,    :open_price, :decimal, precision: 18, scale: 10
  end

  def down
    change_column :transactions, :price, :decimal, precision: 12, scale: 4
    change_column :lots,    :open_price, :decimal, precision: 12, scale: 4
  end
end
