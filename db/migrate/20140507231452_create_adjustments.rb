class CreateAdjustments < ActiveRecord::Migration
  def change
    create_table :adjustments do |t|
      t.date    :date
      t.integer :numerator
      t.integer :denominator
    end

    create_table :adjustments_transactions do |t|
      t.integer :transaction_id, references: :transactions
      t.integer :adjustment_id,  references: :adjustments
    end

    create_table :adjustments_lots do |t|
      t.integer :lot_id,        references: :lots
      t.integer :adjustment_id, references: :adjustments
    end

    change_column :lots,    :open_price, :decimal, precision: 12, scale: 4
    change_column :transactions, :price, :decimal, precision: 12, scale: 4
  end
end
