class CreateRailsAdminTables < ActiveRecord::Migration
  def change
    create_table(:admins) do |t|
      ## Database authenticatable
      t.string :email,              null: false, unique: true
      t.string :encrypted_password, null: false

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.timestamps
    end

    create_table :rails_admin_histories do |t|
      t.text    :message # title, name, or object_id
      t.string  :username
      t.integer :item
      t.string  :table
      t.integer :month, limit: 2
      t.integer :year,  limit: 5

      t.timestamps
      t.index [:item, :table, :month, :year], name: 'index_rails_admin_histories'
    end
  end
end
