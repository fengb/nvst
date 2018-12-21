class PolymorphicOwnership < ActiveRecord::Migration[5.2]
  def change
    change_table :ownerships do |t|
      t.references :source, polymorphic: true, index: true
    end

    reversible do |dir|
      dir.up do
        update_via_join_table 'contributions_ownerships'
        update_via_join_table 'expenses_ownerships'
        update_via_join_table 'ownerships_transfers'
      end

      change_table :ownerships do |t|
        t.change :source_type, :string, null: false
        t.change :source_id, :integer, null: false
      end
    end

    drop_table :contributions_ownerships
    drop_table :expenses_ownerships
    drop_table :ownerships_transfers
  end

  def update_via_join_table(join_table)
    relation = join_table.sub(/_?ownerships_?/, '').singularize
    execute <<-SQL.squish
      UPDATE ownerships
         SET source_type='#{relation.capitalize}'
           , source_id=#{relation}_id
        FROM #{join_table}
       WHERE ownerships.id=ownership_id
    SQL
  end
end
