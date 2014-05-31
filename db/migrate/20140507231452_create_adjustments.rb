class CreateAdjustments < ActiveRecord::Migration
  def up
    create_table :adjustments do |t|
      t.date    :date
      t.integer :numerator
      t.integer :denominator
      t.string  :reason
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

  def down
    drop_table :adjustments_lots
    drop_table :adjustments_transactions
    drop_table :adjustments

    change_column :lots,    :open_price, :decimal, precision: 18, scale: 10
    change_column :transactions, :price, :decimal, precision: 18, scale: 10
  end
end
