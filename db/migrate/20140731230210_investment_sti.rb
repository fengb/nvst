class InvestmentSti < ActiveRecord::Migration
  def change
    change_table :investments do |t|
      t.rename :category, :type
    end

    execute "UPDATE investments SET type='Stock' WHERE type IN ('stock', 'benchmark')"
    execute "UPDATE investments SET type='Cash' WHERE type = 'cash'"
  end
end
