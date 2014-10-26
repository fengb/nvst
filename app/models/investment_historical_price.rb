class InvestmentHistoricalPrice < ActiveRecord::Base
  belongs_to :investment

  validates :date,       presence: true
  validates :close,      presence: true
  validates :high,       presence: true
  validates :low,        presence: true
  validates :adjustment, presence: true

  scope :year_range, ->(end_date=Date.current) { where(date: (end_date - 365)..end_date) }

  def self.previous_of(date)
    where('date < ?', date).order('date DESC').first
  end

  after_initialize do |record|
    record.adjustment ||= 1
  end

  def adjusted(attr)
    self[attr] * self.adjustment
  end
end
