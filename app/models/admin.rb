class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  #  :registerable, :recoverable, :confirmable, :lockable, :validatable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable,
         authentication_keys: [:username]

  def title
    username
  end

  # hack for RailsAdmin
  def email
    username
  end
end
