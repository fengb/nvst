class OwnershipJoinTables < ActiveRecord::Migration
  def change
    create_table :contributions_ownerships do |t|
      t.integer :contribution_id, references: :contributions
      t.integer :ownership_id,    references: :ownerships
    end

    create_table :ownerships_transfers do |t|
      t.integer :ownership_id, references: :ownerships
      t.integer :transfer_id,  references: :transfers
    end

    execute <<-SQL
      INSERT INTO contributions_ownerships(contribution_id, ownership_id)
                                    SELECT c.id,            o.id
                                      FROM contributions c
                                     INNER JOIN ownerships o
                                             ON o.id = c.ownership_id
    SQL

    execute <<-SQL
      INSERT INTO ownerships_transfers(ownership_id, transfer_id)
                                SELECT o.id,         t.id
                                      FROM ownerships o
                                     INNER JOIN transfers t
                                             ON t.from_ownership_id = o.id
                                             OR t.to_ownership_id = o.id
    SQL

    change_table :contributions do |t|
      t.remove :ownership_id
    end

    change_table :transfers do |t|
      t.remove :from_ownership_id
      t.remove :to_ownership_id
    end
  end
end
