require 'spec_helper'
require 'job/populate_investments'

describe Job::PopulateInvestments do
  describe '#split_unadjustment' do
    let(:investment) { FactoryGirl.build(:investment) }
    let(:split) { FactoryGirl.build :investment_split, after: 2, before: 1 }
    subject { Job::PopulateInvestments.new(investment) }

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
