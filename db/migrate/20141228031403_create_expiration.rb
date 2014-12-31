class CreateExpiration < ActiveRecord::Migration
  def change
    create_table :expirations do |t|
      t.integer :investment_id, references: :investments
      t.date    :date
      t.decimal :shares, precision: 15, scale: 4
      t.timestamps
    end

    create_table :activities_expirations do |t|
      t.integer :activity_id,   references: :activities
      t.integer :expiration_id, references: :expirations
    end
  end
end
