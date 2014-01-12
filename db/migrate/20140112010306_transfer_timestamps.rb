class TransferTimestamps < ActiveRecord::Migration
  def change
    change_table :transfers do |t|
      t.timestamps
    end
  end
end
