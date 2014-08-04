class RenameFeeToTransfer < ActiveRecord::Migration
  def change
    rename_table :fees, :transfers

    rename_table :fees_ownerships, :ownerships_transfers
    change_table :ownerships_transfers do |t|
      t.rename :fee_id, :transfer_id
    end
  end
end
