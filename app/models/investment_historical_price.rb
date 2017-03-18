class InvestmentHistoricalPrice < ApplicationRecord
  belongs_to :investment

  validates :date,       presence: true
  validates :close,      presence: true
  validates :high,       presence: true
  validates :low,        presence: true
  validates :adjustment, presence: true

  scope :year_range, ->(end_date=Date.current) { where(date: (end_date - 365)..end_date) }

  scope :start_from, ->(start_date) do
    start_date_rel = self.select('MAX(date)').where('date <= ?', start_date)
    where('date >= (?)', start_date_rel)
  end

  def self.previous_of(date)
    where('date < ?', date).order('date DESC').first
  end

  def self.matcher(column = 'close')
    if block_given?
      array = self.order('date').map do |price|
        [price.date, yield(price)]
      end
      BestMatchHash.new(array)
    else
      BestMatchHash.new(self.order('date').pluck('date', column))
    end
  end

  after_initialize do |record|
    record.adjustment ||= 1
  end

  def adjusted(attr)
    self[attr] * self.adjustment
  end
end
