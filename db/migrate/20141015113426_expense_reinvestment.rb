class ExpenseReinvestment < ActiveRecord::Migration
  def change
    change_table :expenses do |t|
      t.integer :reinvestment_for_user_id, references: :users
    end
  end
end
