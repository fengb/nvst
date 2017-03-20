require 'rails_helper'

describe GenerateOwnershipsJob do
  describe '.classes_needing_processing' do
    it 'includes everything we need' do
      expect(GenerateOwnershipsJob.classes_needing_processing).to include(
        Contribution, Expense, Transfer
      )
    end
  end

  describe '.perform' do
    it 'runs' do
      GenerateOwnershipsJob.classes_needing_processing.each do |model|
        FactoryGirl.create model.name.underscore.to_sym
      end

      allow(PortfolioPresenter).to receive(:all) { double(value_on: 1, cashflow_on: 0) }

      GenerateOwnershipsJob.perform_now
    end
  end
end
