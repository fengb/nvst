class RenameFeeToTransfer < ActiveRecord::Migration
  def change
    rename_table :fees, :transfers
    change_table :transfers do |t|
      t.integer :to_user_id, references: :users
    end

    rename_table :fees_ownerships, :ownerships_transfers
    change_table :ownerships_transfers do |t|
      t.rename :fee_id, :transfer_id
    end

    fee_collecting_id = User.fee_collector.id
    execute "UPDATE transfers SET to_user_id=#{fee_collecting_id}"
  end
end
