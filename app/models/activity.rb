# Generated
class Activity < ApplicationRecord
  include Scopes::Year

  belongs_to :position
  belongs_to :source, polymorphic: true
  has_and_belongs_to_many :adjustments, class_name: 'ActivityAdjustment'

  validates :position, presence: true
  validates :date,     presence: true
  validates :tax_date, presence: true
  validates :shares,   presence: true
  validates :price,    presence: true

  delegate :investment, to: :position

  scope :tracked, ->{joins(position: :investment).where("investments.type != 'Investment::Cash'")}
  scope :opening, ->{where(is_opening: true)}
  scope :closing, ->{where(is_opening: false)}
  scope :buy,  ->{where('shares > 0')}
  scope :sell, ->{where('shares < 0')}

  def value
    -shares * adjusted_price
  end

  def cost_basis
    -shares * position.opening(:adjusted_price)
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

  def buy?
    shares > 0
  end

  def sell?
    shares < 0
  end

  def adjusted_price(on: Date.current)
    price * adjustments.ratio(on: on)
  end
end
