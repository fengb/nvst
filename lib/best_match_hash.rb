# Return a "best match" value when one is not found
# Useful for things that change but not necessarily regularly (e.g. stock prices)

# Example:
# >> h = BestMatchHash.new({'2013-01-01' => 50, '2013-01-05' => 60}, 40)
# >> bmd['2012-12-31']
# => 40
# >> bmd['2013-01-01']
# => 50
# >> bmd['2013-01-04']
# => 50
# >> bmd['2013-01-05']
# => 60
# >> bmd['9999-01-01']
# => 60
class BestMatchHash
  def initialize(hash, default=nil)
    @items = hash.sort.reverse
    @default = default
  end

  def [](key)
    found = @items.bsearch{|x| x[0] <= key}
    found ? found[1] : @default
  end

  def each
    @items.reverse_each do |item|
      yield *item
    end
  end

  def keys
    @items.map(&:first).reverse
  end

  def self.sum(hash)
    sum = 0
    sum_by_key = {}
    hash.sort.each do |key, value|
      sum += value
      sum_by_key[key] = sum
    end
    self.new(sum_by_key, 0)
  end
end
