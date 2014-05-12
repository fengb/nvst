# Generated
class Transaction < ActiveRecord::Base
  include Scopes::Year

  belongs_to :lot

  validates :lot, presence: true

  delegate :investment, to: :lot

  has_and_belongs_to_many :adjustments

  scope :tracked, ->{joins(lot: :investment).where("investments.category != 'cash'")}
  scope :opening, ->{where(is_opening: true)}
  scope :closing, ->{where(is_opening: false)}

  def value
    -shares * adjusted_price
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
    price * adjustments.ratio(on: on)
  end
end
