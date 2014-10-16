class Expense < ActiveRecord::Base
  extend Enumerize
  include GenerateActivitiesWaterfall
  include GenerateOwnerships
  include Scopes::Year

  belongs_to :reinvestment_for_user
  has_and_belongs_to_many :activities
  has_and_belongs_to_many :ownerships

  validates :date,   presence: true
  validates :amount, presence: true
  validates :vendor, presence: true

  enumerize :category, in: {'salaries and wages'        => 'sal',
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
                            'other'                     => 'oth'}

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
      units: ownership_units(at: date, amount: amount, cashflow: false)}]
  end

  def cashflow_amount
    return 0 if reinvestment_for_user
    -amount
  end

  def net_amount
    return 0 if reinvestment_for_user
    -amount
  end

  def description
    "#{category} - #{vendor} - #{memo}"
  end
end
