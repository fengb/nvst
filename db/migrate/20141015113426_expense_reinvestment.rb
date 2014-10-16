class ExpenseReinvestment < ActiveRecord::Migration
  def change
    change_table :expenses do |t|
      t.integer :reinvestment_for_user_id, references: :users
    end

    create_table :expenses_ownerships do |t|
      t.integer :expense_id, references: :expenses
      t.integer :ownership_id, references: :ownerships
    end
  end
end
