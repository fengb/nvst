class ContributionUnits < ActiveRecord::Migration
  def change
    change_table :contributions do |t|
      t.decimal :units, precision: 18, scale: 8
    end
  end
end
