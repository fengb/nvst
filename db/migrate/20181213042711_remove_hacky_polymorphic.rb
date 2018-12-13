class RemoveHackyPolymorphic < ActiveRecord::Migration[5.0]
  def change
    drop_table :activities_contributions
    drop_table :activities_expenses
    drop_table :activities_expirations
    drop_table :activities_events
    drop_table :activities_trades

    remove_column :investment_splits, :activity_adjustment_id
  end
end
