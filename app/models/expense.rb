class Expense < ActiveRecord::Base
  extend Enumerize
  include GenerateActivitiesWaterfall
  include Scopes::Year

  has_and_belongs_to_many :activities

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
    [{investment: Investment::Cash.first,
      date:       date,
      shares:     cashflow_amount,
      price:      1}]
  end

  def cashflow_amount
    -amount
  end

  def net_amount
    -amount
  end

  def description
    "#{category} - #{vendor} - #{memo}"
  end
end
