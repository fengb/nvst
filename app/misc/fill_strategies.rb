class FillStrategies
  def self.default=(strategy)
    @default = strategy
  end

  def self.default
    @default ||= :tax_efficient_harvester
  end

  def self.run(positions, new_price, strategy=nil)
    self.new(positions, new_price).send(strategy || default)
  end

  def initialize(positions, options={})
    @positions = positions

    @new_price = options[:new_price]
    @new_date = options[:new_date] || Date.current
  end

  def fifo
    @positions.sort_by{|p| [p.opening(:date), p.id]}
  end

  def highest_cost_first
    @positions.sort_by{|p| [-p.opening(:adjusted_price), p.opening(:date)]}
  end

  def tax_efficient_harvester
    @positions.sort_by do |p|
      # Magic numbers galore!
      tax_rate = if @new_date - p.opening(:date) < 365
                   0.28
                 else
                   0.15
                 end
      (@new_price - p.opening(:adjusted_price)) * tax_rate
    end
  end
end
