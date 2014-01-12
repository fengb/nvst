require 'spec_helper'


describe GenerateOwnerships do
  describe '#generate_ownerships!' do
    class TestClass < OpenStruct
      include GenerateOwnerships
    end

    let(:instance) { TestClass.new(ownerships: [], raw_ownerships_data: []) }

    context 'already has ownerships' do
      before { instance.ownerships = [1] }

      it 'returns nil' do
        expect(instance.generate_ownerships!).to be(nil)
      end

      it 'does absolutely nothing' do
        instance.ownerships.should_not_receive(:create!)
        instance.generate_ownerships!
      end
    end
  end
end
