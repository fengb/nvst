class InvestmentCategory < ActiveRecord::Migration
  def change
    change_table :investments do |t|
      t.string :category
      t.remove :auto_update
    end
  end
end
