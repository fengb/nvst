class TransactionTaxDate < ActiveRecord::Migration
  def change
    change_table :transactions do |t|
      t.date :tax_date
    end
  end
end
