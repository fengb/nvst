require 'rails_helper'

describe GenerateActivitiesJob do
  describe '.classes_needing_processing' do
    it 'includes everything we need' do
      expect(GenerateActivitiesJob.classes_needing_processing).to include(
        Contribution, Event, Expense, Expiration, InvestmentSplit, Trade
      )
    end
  end

  describe '.perform' do
    it 'runs' do
      GenerateActivitiesJob.classes_needing_processing.each do |model|
        FactoryGirl.create model
      end

      GenerateActivitiesJob.perform_now
    end
  end
end
