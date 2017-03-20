# Generated
class Ownership < ApplicationRecord
  belongs_to :user

  validates :user,  presence: true
  validates :date,  presence: true
  validates :units, presence: true

  def self.total_on(date)
    where('date <= ?', date).sum(:units)
  end
end
