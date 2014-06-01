class RenameLotTransactions < ActiveRecord::Migration
  def change
    rename_transactions!
    rename_lots!
  end

  def rename_transactions!
    rename_table :transactions, :activities
    rename_table :transaction_adjustments, :activity_adjustments

    rename_table :transaction_adjustments_transactions, :activities_activity_adjustments
    change_table :activities_activity_adjustments do |t|
      t.rename :transaction_id, :activity_id
      t.rename :transaction_adjustment_id, :activity_adjustment_id
    end

    rename_column :investment_splits, :transaction_adjustment_id, :activity_adjustment_id

    %w[contributions events expenses trades].each do |relation|
      new_name = "activities_#{relation}"
      rename_table "#{relation}_transactions", new_name
      rename_column new_name, :transaction_id, :activity_id
    end
  end

  def rename_lots!
    rename_table :lots, :positions
    rename_column :activities, :lot_id, :position_id
  end
end
