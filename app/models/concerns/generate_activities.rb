module GenerateActivities
  extend ModelsIncluded

  def generate_activities!
    return if activities.count > 0

    ActiveRecord::Base.transaction do
      raw_activities_data.each do |data|
        activities = GenerateActivities.execute!(data)
        self.activities.concat(activities)
      end
    end

    self.activities
  end

  class << self
    def execute!(data)
      data[:tax_date] ||= data[:date]

      if corresponding = Lot.corresponding(data)
        data = data.slice(:date, :tax_date, :price, :shares)
                   .merge(lot:         corresponding,
                          adjustments: corresponding.opening(:adjustments))

        return [Activity.create!(data)]
      end

      if data[:adjustment] && data[:adjustment] != 1
        adjustment = ActivityAdjustment.new(date:   data[:date],
                                            ratio:  data[:adjustment],
                                            reason: 'fee')
      end

      shared_data = data.slice(:date, :tax_date, :price)
      shared_data[:adjustments] = [adjustment].compact

      investment = data[:investment]
      remaining_shares = data[:shares]

      activities = []
      open_lots(investment, remaining_shares).each do |lot|
        if lot.outstanding_shares.abs >= remaining_shares.abs
          activities << lot.activities.create!(shared_data.merge shares: remaining_shares)
          return activities
        else
          remaining_shares += lot.outstanding_shares
          activities << lot.activities.create!(shared_data.merge shares: -lot.outstanding_shares)
        end
      end

      # Shares remaining with no lot
      lot = Lot.new(investment:  investment)
      activities << Activity.create!(shared_data.merge lot: lot,
                                                       shares: remaining_shares,
                                                       is_opening: true)
      activities
    end

    def open_lots(investment, new_shares)
      # Buy shares fill -outstanding, sell shares fill +outstanding
      direction = new_shares > 0 ? '-' : '+'
      LotStrategies.highest_cost_first(investment, direction)
    end

    class LotStrategies
      class << self
        def fifo(investment, direction)
          Lot.open(direction: direction).where(investment: investment)
                                        .sort_by{|l| [l.opening(:date), l.id]}
        end

        def highest_cost_first(investment, direction)
          Lot.open(direction: direction).where(investment: investment)
                                        .sort_by{|l| [-l.opening(:price), l.opening(:date), l.id]}
        end
      end
    end
  end
end
