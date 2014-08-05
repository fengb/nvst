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
      open_positions(investment, remaining_shares).each do |position|
        if position.outstanding_shares.abs >= remaining_shares.abs
          activities << position.activities.create!(shared_data.merge shares: remaining_shares)
          return activities
        else
          remaining_shares += position.outstanding_shares
          activities << position.activities.create!(shared_data.merge shares: -position.outstanding_shares)
        end
      end

      # Shares remaining with no position
      position = Position.new(investment:  investment)
      activities << Activity.create!(shared_data.merge position: position,
                                                       shares: remaining_shares,
                                                       is_opening: true)
      activities
    end

    def open_positions(investment, new_shares)
      # +shares fill short, -shares fill long
      direction = new_shares > 0 ? :short : :long
      positions = Position.where(investment: investment).open(direction: direction)
      FillStrategies.for(positions)
    end

    class FillStrategies
      def self.for(positions)
        self.new(positions).highest_cost_first
      end

      def initialize(positions)
        @positions = positions
      end

      def fifo
        @positions.sort_by{|p| [p.opening(:date), p.id]}
      end

      def highest_cost_first
        @positions.sort_by{|p| [-p.opening(:price), p.opening(:date)]}
      end
    end
  end
end
