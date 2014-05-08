class CreateAdjustments < ActiveRecord::Migration
  def change
    create_table :adjustments do |t|
      t.date    :date
      t.integer :numerator
      t.integer :denominator
    end

    create_table :adjustment_transactions do |t|
      t.integer :transaction_id, references: :transactions
      t.integer :adjustment_id,  references: :adjustments
    end
  end
end
