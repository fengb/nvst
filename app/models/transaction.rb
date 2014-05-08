# Generated
class Transaction < ActiveRecord::Base
  include Scopes::Year

  belongs_to :lot

  validates :lot, presence: true

  delegate :investment, to: :lot

  has_and_belongs_to_many :adjustments

  scope :tracked, ->{joins(lot: :investment).where("investments.category != 'cash'")}
  scope :open,    ->{joins(:lot).where('lots.open_date = transactions.date AND lots.open_price = transactions.price')}
  scope :close,   ->{joins(:lot).where('lots.open_date != transactions.date OR lots.open_price != transactions.price')}

  def value
    -shares * price
  end

  def cost_basis
    -shares * lot.open_price
  end

  def realized_gain
    value - cost_basis
  end

  def open?
    date == lot.open_date && price == lot.open_price
  end

  def close?
    date != lot.open_date || price != lot.open_price
  end

  def adjusted_price(on: Date.today)
    price * adjustments.select{|adj| adj.date <= on}.map(&:ratio).inject(1, :*)
  end
end
