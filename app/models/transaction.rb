# Generated
class Transaction < ActiveRecord::Base
  include Scopes::Year

  belongs_to :lot

  validates :lot, presence: true

  validates :date,     presence: true
  validates :tax_date, presence: true
  validates :shares,   presence: true
  validates :price,    presence: true

  delegate :investment, to: :lot

  has_and_belongs_to_many :adjustments, class_name: 'TransactionAdjustment'

  scope :tracked, ->{joins(lot: :investment).where("investments.category != 'cash'")}
  scope :opening, ->{where(is_opening: true)}
  scope :closing, ->{where(is_opening: false)}

  def value
    -shares * adjusted_price
  end

  def cost_basis
    -shares * lot.opening(:price)
  end

  def realized_gain
    value - cost_basis
  end

  def opening?
    is_opening?
  end

  def closing?
    !is_opening?
  end

  def adjusted_price(on: Date.today)
    price * adjustments.ratio(on: on)
  end
end
