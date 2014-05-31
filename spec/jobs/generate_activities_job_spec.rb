require 'spec_helper'

describe GenerateActivitiesJob do
  describe '.all_models' do
    it 'includes everything we need' do
      expect(GenerateActivitiesJob.all_models).to include(
        Contribution, Event, Expense, InvestmentSplit, Trade
      )
    end
  end

  describe '.perform' do
    it 'runs' do
      GenerateActivitiesJob.all_models.each do |model|
        FactoryGirl.create model
      end

      GenerateActivitiesJob.perform
    end
  end
end
