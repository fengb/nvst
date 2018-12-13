require 'rails_helper'

describe ActivityAdjustment do
  describe '.ratio' do
    let!(:activity) do
      FactoryBot.create(:activity).tap do |activity|
        activity.adjustments.create(source: activity, date: '2013-01-01', ratio: 2, reason: 'split')
        activity.adjustments.create(source: activity, date: '2013-02-01', ratio: 3, reason: 'split')
        activity.adjustments.create(source: activity, date: '2013-03-01', ratio: 5, reason: 'split')
      end
    end

    it 'aggregates everything' do
      expect(activity.adjustments.ratio).to eq(2*3*5)
    end

    it 'aggregates everything up to a date' do
      expect(activity.adjustments.ratio(on: '2013-02-05'.to_date)).to eq(2*3)
    end
  end
end
