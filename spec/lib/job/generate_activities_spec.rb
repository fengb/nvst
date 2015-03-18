require 'rails_helper'
require 'job/generate_activities'

describe Job::GenerateActivities do
  describe '.classes_needing_processing' do
    it 'includes everything we need' do
      expect(Job::GenerateActivities.classes_needing_processing).to include(
        Contribution, Event, Expense, Expiration, InvestmentSplit, Trade
      )
    end
  end

  describe '.perform' do
    it 'runs' do
      Job::GenerateActivities.classes_needing_processing.each do |model|
        FactoryGirl.create model
      end

      Job::GenerateActivities.perform
    end
  end
end
