class TransactionAdjustments < ActiveRecord::Migration
  def change
    rename_table :adjustments, :transaction_adjustments
    rename_table :adjustments_transactions, :transaction_adjustments_transactions

    change_table :transaction_adjustments_transactions do |t|
      t.rename :adjustment_id, :transaction_adjustment_id
    end

    change_table :investment_splits do |t|
      t.integer :transaction_adjustment_id, references: :transaction_adjustments
    end
  end
end
