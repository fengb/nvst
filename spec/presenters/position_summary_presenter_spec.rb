require 'spec_helper'


describe PositionSummaryPresenter do
  describe '#unique_by' do
    it 'returns the unique item' do
      l = PositionSummaryPresenter.new([
        double(key: 'uno'),
        double(key: 'uno'),
      ])
      expect(l.send(:unique_by, :key)).to eq('uno')
    end

    it 'returns nil when the fields are not unique' do
      l = PositionSummaryPresenter.new([
        double(key: 'uno'),
        double(key: 'dos'),
      ])
      expect(l.send(:unique_by, :key)).to be(nil)
    end
  end

  describe '#sum_by' do
    it 'returns the sum item' do
      l = PositionSummaryPresenter.new([
        double(key: 12),
        double(key: 34),
      ])
      expect(l.send(:sum_by, :key)).to eq(46)
    end
  end

  describe 'public instance methods' do
    let(:positions) do
      [ FactoryGirl.create(:position),
        FactoryGirl.create(:position) ]
    end
    subject { PositionSummaryPresenter.new(positions) }

    before do
      positions.each do |position|
        allow(position).to receive_messages(current_price: 1)
      end
    end

    accessor_methods = PositionSummaryPresenter.public_instance_methods(false).select do |method_name|
      method = PositionSummaryPresenter.instance_method(method_name)
      method.arity == 0
    end

    accessor_methods.each do |method_name|
      specify "#{method_name} works" do
        expect{subject.send(method_name)}.to_not raise_error
      end
    end

    specify '#opening works' do
      expect{subject.opening(:date)}.to_not raise_error
      expect{subject.opening(:price)}.to_not raise_error
    end
  end
end
