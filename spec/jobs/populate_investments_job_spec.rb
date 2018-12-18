require 'rails_helper'

describe PopulateInvestmentsJob do
  describe '#split_unadjustment' do
    let(:investment) { FactoryBot.build(:investment) }
    let(:split) { FactoryBot.build :investment_split, after: 2, before: 1 }
    subject { PopulateInvestmentsJob::Processor.new(investment) }

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
