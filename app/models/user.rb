class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :registerable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :contributions
  has_many :ownerships

  scope :fee_collecting, ->{where(is_fee_collector: false)}
  def self.fee_collector
    find_by(is_fee_collector: true)
  end

  rails_admin do
    object_label_method :email
  end
end
