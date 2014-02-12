require 'spec_helper'


describe GenerateOwnerships do
  describe '#generate_ownerships!' do
    class TestClass < OpenStruct
      include GenerateOwnerships
    end

    subject { TestClass.new(ownerships: [], raw_ownerships_data: []) }

    context 'already has ownerships' do
      before { subject.ownerships = [1] }

      it 'returns nil' do
        expect(subject.generate_ownerships!).to be(nil)
      end

      it 'does absolutely nothing' do
        subject.ownerships.should_not_receive(:create!)
        subject.generate_ownerships!
      end
    end
  end
end
