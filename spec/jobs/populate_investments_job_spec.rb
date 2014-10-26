require 'spec_helper'

describe PopulateInvestmentsJob do
  describe '#split_unadjustment' do
    subject { PopulateInvestmentsJob.new(FactoryGirl.build :investment) }
    let(:split) { FactoryGirl.build :investment_split, after: 2, before: 1 }
    before do
      allow(subject).to receive(:splits) { [split] }
    end

    it 'unadjusts when earlier than split' do
      expect(subject.split_unadjustment(split.date - 1)).to eq(2)
    end

    it 'does nothing when later than split' do
      expect(subject.split_unadjustment(split.date + 1)).to eq(1)
    end
  end
end
