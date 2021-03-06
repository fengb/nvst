class Expense < ApplicationRecord
  include GenerateActivitiesWaterfall
  include GenerateOwnerships
  include Scopes::Year

  belongs_to :reinvestment_for_user, class_name: 'User', optional: true
  has_many :activities, as: :source
  has_many :ownerships, as: :source

  validates :date,   presence: true
  validates :amount, presence: true
  validates :vendor, presence: true

  enum category: {
    'salaries and wages'        => 'sal',
    'payments'                  => 'pay',
    'repairs and maintenance'   => 'rep',
    'bad debts'                 => 'deb',
    'rent'                      => 'ren',
    'taxes and licenses'        => 'tax',
    'interest'                  => 'int',
    'depreciation'              => 'dpr',
    'depletion'                 => 'dpl',
    'retirement plans'          => 'ret',
    'employee benefit programs' => 'ben',
    'other'                     => 'oth',
  }

  scope :cashflow, -> { where(reinvestment_for_user_id: nil) }

  def self.as_transactions
    all.map do |expense|
      Transaction.new(
        date: expense.date,
        net_amount: -expense.amount,
        class_name: expense.class.to_s,
        description: "#{expense.category} - #{expense.vendor} - #{expense.memo}",
      )
    end
  end

  def raw_activities_data
    return [] if reinvestment_for_user

    [{investment: Investment::Cash.first,
      date:       date,
      shares:     cashflow_amount,
      price:      1}]
  end

  def raw_ownerships_data
    return [] unless reinvestment_for_user

    [{user: reinvestment_for_user,
      date: date,
      units: ownership_units(on: date, amount: amount, cashflow: false)}]
  end

  def cashflow_amount
    reinvestment_for_user_id ? 0 : -amount
  end
end
