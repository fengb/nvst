require 'time_cache'

describe TimeCache do
  let(:expiry) { 10 }
  let(:cache)  { TimeCache.new(expiry) }

  it 'stores and retrieves values' do
    cache[1] = 'one'
    expect(cache[1]).to eq('one')
  end

  it 'expires after "expiry" seconds' do
    cache[2] = 'two'
    Timecop.travel(expiry) do
      expect(cache[2]).to be(nil)
    end
  end

  it 'does not expire when exactly "expiry" seconds' do
    Timecop.freeze do
      cache[3] = 'three'
      Timecop.freeze(expiry) do
        expect(cache[3]).to eq('three')
      end
    end
  end

  it 'expires when explicitly expiring' do
    cache[4] = 'four'
    cache.expire!(4)
    expect(cache[4]).to be(nil)
  end

  it 'expires all' do
    cache[3] = 'three'
    cache[4] = 'four'
    cache.expire_all!
    expect(cache[3]).to be(nil)
    expect(cache[4]).to be(nil)
  end
end
