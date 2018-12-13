module GenerateActivitiesWaterfall
  def generate_activities!
    return if activities.count > 0

    ActiveRecord::Base.transaction do
      raw_activities_data.each do |data|
        activities = GenerateActivitiesWaterfall.execute!(source: self, **data)
        self.activities.concat(activities)
      end
    end

    self.activities
  end

  class << self
    def execute!(**data)
      data[:tax_date] ||= data[:date]

      shared_data = data.slice(:date, :tax_date, :price, :source)
      shared_data[:adjustments] = Array(adjustment_for(data))

      investment = data[:investment]
      remaining_shares = data[:shares]

      activities = []
      open_positions(investment, remaining_shares, data[:price]).each do |position|
        if position.outstanding_shares.abs >= remaining_shares.abs
          activities << position.activities.create!(**shared_data, shares: remaining_shares)
          return activities
        else
          remaining_shares += position.outstanding_shares
          activities << position.activities.create!(**shared_data, shares: -position.outstanding_shares)
        end
      end

      # Shares remaining with no position
      activities << Activity.create!(
                      **shared_data,
                      position: Position.new(investment: investment),
                      shares: remaining_shares,
                      is_opening: true,
                    )
      activities
    end

    def adjustment_for(data)
      if data[:adjustment] && data[:adjustment] != 1
        ActivityAdjustment.new(source: data[:source],
                               date:   data[:date],
                               ratio:  data[:adjustment],
                               reason: 'fee')
      end
    end

    def open_positions(investment, new_shares, new_price)
      # +shares fill short, -shares fill long
      direction = new_shares > 0 ? :short : :long

      positions = Position.open.send(direction).where(investment: investment).includes(:activities)
      FillStrategies.run(positions, new_price: new_price)
    end
  end
end
