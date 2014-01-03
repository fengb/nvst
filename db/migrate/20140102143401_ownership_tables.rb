class OwnershipTables < ActiveRecord::Migration
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

    create_table :transfers do |t|
      t.date    :date
      t.decimal :amount, precision: 21, scale: 8
      t.integer :from_user_id,      references: :users
      t.integer :to_user_id,        references: :users
      t.integer :from_ownership_id, references: :ownerships
      t.integer :to_ownership_id,   references: :ownerships
    end
  end
end
