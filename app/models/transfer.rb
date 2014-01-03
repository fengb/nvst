class Transfer < ActiveRecord::Base
  belongs_to :from_user,      class_name: 'User'
  belongs_to :to_user,        class_name: 'User'
  belongs_to :from_ownership, class_name: 'Ownership'
  belongs_to :to_ownership,   class_name: 'Ownership'

  def ownerships
    [from_ownership, to_ownership]
  end

  def generate_ownerships!
    self.build_from_ownership(user: from_user, date: date, units: -amount)
    self.build_to_ownership(user: to_user, date: date, units: amount)
    self.save!
  end
end
