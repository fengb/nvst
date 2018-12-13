class PolymorphicActivityAdjustmentSource < ActiveRecord::Migration[5.0]
  def change
    change_table :activity_adjustments do |t|
      t.references :source, polymorphic: true, index: true
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE activity_adjustments
             SET source_type='InvestmentSplit'
               , source_id=investment_splits.id
            FROM investment_splits
           WHERE activity_adjustments.reason='split'
             AND investment_splits.activity_adjustment_id=activity_adjustments.id
        SQL

        execute <<-SQL.squish
          UPDATE activity_adjustments
             SET source_type=activities.source_type
               , source_id=activities.id
            FROM activities, activities_activity_adjustments
           WHERE activity_adjustments.reason='fee'
             AND activity_adjustment_id=activity_adjustments.id
             AND activities.id=activity_id
        SQL

        change_table :activity_adjustments do |t|
          t.change :source_type, :string, null: false
          t.change :source_id, :integer, null: false
        end
      end
    end
  end
end
