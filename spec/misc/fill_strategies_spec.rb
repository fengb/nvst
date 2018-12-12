require 'rails_helper'


describe FillStrategies do
  def position_for(data)
    FactoryBot.create(:position, opening_activity: data)
  end

  let(:positions) do
    [ position_for(date: '2013-01-01', price: 100),
      position_for(date: '2014-01-01', price: 149),
      position_for(date: '2015-01-01', price: 150)]
  end
  let(:options) do
    { new_date: '2015-01-02'.to_date,
      new_price: 200 }
  end

  def positions_at(*indexes)
    indexes.map{|i| positions[i]}
  end

  subject { FillStrategies.new(positions, options) }

  specify 'fifo returns positions sorted by date' do
    expect(subject.fifo).to eq(positions)
  end

  specify 'highest_cost_first returns positions sorted by cost' do
    expect(subject.highest_cost_first).to eq(positions_at(2, 1, 0))
  end

  specify 'tax_efficient_harvester returns positions sorted by least tax' do
    # position 1 is long-term so it has lower tax rate than position 2
    expect(subject.tax_efficient_harvester()).to eq(positions_at(1, 2, 0))
  end
end
