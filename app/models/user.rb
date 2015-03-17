class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :registerable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :contributions
  has_many :ownerships
  has_many :reinvestments, class_name: 'Expense', foreign_key: :reinvestment_for_user_id

  scope :fee_collecting, ->{where(is_fee_collector: false)}
  def self.fee_collector
    find_by(is_fee_collector: true)
  end

  # FIXME: year crap
  scope :active_in, ->(year) { all }

  def active_years
    # FIXME
    [2013, 2014]
  end


  def username
    email.sub(/@.*/, '')
  end

  def to_s
    username
  end
end
