class Categories < ActiveRecord::Migration
  def change
    change_table :expenses do |t|
      t.string :category
    end

    change_table :events do |t|
      t.rename :reason, :category
    end
  end
end
