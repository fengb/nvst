class Ownership < ActiveRecord::Base
  belongs_to :user

  def self.total_at(date)
    where('date <= ?', date).sum(:units)
  end
end
