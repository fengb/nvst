# Generated
class Ownership < ActiveRecord::Base
  belongs_to :user

  validates :user,  presence: true
  validates :date,  presence: true
  validates :units, presence: true

  def self.total_at(date)
    where('date <= ?', date).sum(:units)
  end
end
