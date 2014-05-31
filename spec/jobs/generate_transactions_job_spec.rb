require 'spec_helper'

describe GenerateTransactionsJob do
  describe '.all_models' do
    it 'includes everything we need' do
      expect(GenerateTransactionsJob.all_models).to include(
        Contribution, Event, Expense, InvestmentSplit, Trade
      )
    end
  end

  describe '.perform' do
    it 'runs' do
      GenerateTransactionsJob.all_models.each do |model|
        FactoryGirl.create model
      end

      GenerateTransactionsJob.perform
    end
  end
end
