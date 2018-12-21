# Generated
class Ownership < ApplicationRecord
  belongs_to :user
  belongs_to :source, polymorphic: true

  validates :user,  presence: true
  validates :date,  presence: true
  validates :units, presence: true

  def self.total_on(date)
    where('date <= ?', date).sum(:units)
  end
end
