class CreateTradeTables < ActiveRecord::Migration
  def change
    create_table :contributions do |t|
      t.integer :user_id, references: :users
      t.date    :date
      t.decimal :amount, precision: 18, scale: 4

      t.timestamps
    end

    create_table :trades do |t|
      t.date    :date

      t.integer :sell_investment_id, references: :investments
      t.decimal :sell_shares, precision: 15, scale: 4
      t.decimal :sell_price,  precision: 12, scale: 4

      t.integer :buy_investment_id, references: :investments
      t.decimal :buy_shares, precision: 15, scale: 4
      t.decimal :buy_price,  precision: 12, scale: 4

      t.timestamps
    end

    create_table :events do |t|
      t.integer :src_investment_id, references: :investments
      t.date    :date
      t.decimal :amount, precision: 12, scale: 4
      t.string  :reason

      t.timestamps
    end

    create_table :expenses do |t|
      t.date    :date
      t.decimal :amount, precision: 12, scale: 4
      t.string  :vendor
      t.string  :memo

      t.timestamps
    end

    create_table :lots do |t|
      t.integer :investment_id, references: :investments
    end

    create_table :transactions do |t|
      t.integer :lot_id, references: :lots
      t.date    :date
      t.decimal :shares, precision: 15, scale: 4
      t.decimal :price,  precision: 12, scale: 4
    end

    create_table :contributions_transactions do |t|
      t.integer :contribution_id, references: :contributions, index: true
      t.integer :transaction_id,  references: :transactions,  index: {unique: true}
    end

    create_table :trades_transactions do |t|
      t.integer :trade_id,       references: :trades,       index: true
      t.integer :transaction_id, references: :transactions, index: {unique: true}
    end

    create_table :events_transactions do |t|
      t.integer :event_id,       references: :events,       index: true
      t.integer :transaction_id, references: :transactions, index: {unique: true}
    end

    create_table :expenses_transactions do |t|
      t.integer :expense_id,     references: :expenses,     index: true
      t.integer :transaction_id, references: :transactions, index: {unique: true}
    end
  end
end
