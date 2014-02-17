class RenameFees < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.boolean :is_fee_collector, default: false
    end

    rename_table :transfers, :fees
    change_table :fees do |t|
      t.remove :to_user_id
    end

    rename_table :ownerships_transfers, :fees_ownerships
    change_table :fees_ownerships do |t|
      t.rename :transfer_id, :fee_id
    end
  end

  def down
    change_table :users do |t|
      t.remove :is_fee_collector
    end

    rename_table :fees, :transfers
    change_table :transfers do |t|
      t.integer :to_user_id, references: :users
    end

    rename_table :fees_ownerships, :ownerships_transfers
    change_table :ownerships_transfers do |t|
      t.rename :fee_id, :transfer_id
    end
  end
end
