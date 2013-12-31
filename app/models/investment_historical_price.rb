# Generated
require 'time_cache'


class InvestmentHistoricalPrice < ActiveRecord::Base
  belongs_to :investment

  default_scope ->{order(:date)}

  scope :year_range, ->(end_date=Date.today) { where(date: (end_date - 365)..end_date) }

  def self.latest_raw_adjustment(investment_id)
    @cache ||= TimeCache.new(600) # 10 minute expiration
    investment_id = investment_id.id if investment_id.instance_of?(Investment)
    @cache[investment_id] ||= where(investment_id: investment_id).last.raw_adjustment
  end

  def adjusted(attr)
    self[attr] * self.adjustment
  end

  def adjustment
    raw_adjustment / self.class.latest_raw_adjustment(investment)
  end
end
