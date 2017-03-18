class Transfer < ApplicationRecord
  include GenerateOwnerships
  include Scopes::Year

  belongs_to :from_user, class_name: 'User'
  belongs_to :to_user,   class_name: 'User'
  has_and_belongs_to_many :ownerships

  validates :date,      presence: true
  validates :amount,    presence: true
  validates :from_user, presence: true
  validates :to_user,   presence: true

  scope :fees, ->{where(to_user: User.fee_collector)}

  def from_ownership
    ownerships.find_by('units < 0')
  end

  def to_ownership
    ownerships.find_by('units > 0')
  end

  def raw_ownerships_data
    [{user: from_user,
      date: date,
      units: -ownership_units(at: date, amount: amount)},
     {user: to_user,
      date: date,
      units: ownership_units(at: date, amount: amount)}
    ]
  end
end
