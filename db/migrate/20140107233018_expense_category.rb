class ExpenseCategory < ActiveRecord::Migration
  def change
    change_table :expenses do |t|
      t.string :category
    end
  end
end
