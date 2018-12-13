class PolymorphicActivitySource < ActiveRecord::Migration[5.0]
  def change
    change_table :activities do |t|
      t.references :source, polymorphic: true, index: true
    end

    reversible do |dir|
      dir.up do
        update_via_join 'contribution'
        update_via_join 'expense'
        update_via_join 'expiration'
        update_via_join 'event'
        update_via_join 'trade'

        update_nils

        change_table :activities do |t|
          t.change :source_type, :string, null: false
          t.change :source_id, :integer, null: false
        end
      end
    end
  end

  def update_via_join(relation)
    execute <<-SQL.squish
      UPDATE activities
         SET source_type='#{relation.capitalize}'
           , source_id=#{relation}_id
        FROM activities_#{relation}s
       WHERE activities.id=activity_id
    SQL
  end

  def update_nils
    # Split generated activities don't have a synthetic source. Oops...
    execute <<-SQL.squish
      UPDATE activities
         SET source_type='InvestmentSplit'
           , source_id=investment_splits.id
        FROM positions, investment_splits
       WHERE activities.source_id IS NULL
         AND positions.id=activities.position_id
         AND investment_splits.date=activities.date
         AND investment_splits.investment_id=positions.investment_id
    SQL
  end
end
