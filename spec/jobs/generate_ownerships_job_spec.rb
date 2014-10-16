require 'spec_helper'

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
        FactoryGirl.create model
      end

      GenerateOwnershipsJob.perform
    end
  end
end
