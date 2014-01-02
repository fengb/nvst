class CreateOwnerships < ActiveRecord::Migration
  def change
    create_table :ownerships do |t|
      t.integer :user_id, references: :users
      t.date    :date
      t.decimal :units, precision: 18, scale: 8

      t.timestamps
    end

    change_table :contributions do |t|
      t.integer :ownership_id, references: :ownerships
    end
  end
end
