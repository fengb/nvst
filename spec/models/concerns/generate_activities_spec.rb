require 'spec_helper'


describe GenerateActivitiesWaterfall do
  describe '#generate_activities!' do
    class TestClass < OpenStruct
      include GenerateActivitiesWaterfall
    end

    subject { TestClass.new(activities: [], raw_activities_data: []) }

    context 'already has activities' do
      before { subject.activities = [1] }

      it 'returns nil' do
        expect(subject.generate_activities!).to be(nil)
      end

      it 'does absolutely nothing' do
        expect(GenerateActivitiesWaterfall).to_not receive(:execute!)
        subject.generate_activities!
      end
    end

    it 'passes raw activity data to GenerateActivitiesWaterfall.execute!' do
      subject.raw_activities_data = [4, 2, 5]
      expect(GenerateActivitiesWaterfall).to receive(:execute!).with(4).and_return([4])
      expect(GenerateActivitiesWaterfall).to receive(:execute!).with(2).and_return([2])
      expect(GenerateActivitiesWaterfall).to receive(:execute!).with(5).and_return([5])

      subject.generate_activities!
    end

    it 'adds GenerateActivitiesWaterfall.execute! returned values to activities' do
      subject.raw_activities_data = [:a, :z]
      allow(GenerateActivitiesWaterfall).to receive_messages(execute!: [1, 2])

      subject.generate_activities!
      expect(subject.activities).to eq([1, 2, 1, 2])
    end
  end

  describe '.execute!' do
    let(:investment) { FactoryGirl.create(:investment) }
    let(:data)       { {investment: investment,
                        date:       Date.current - rand(1000),
                        shares:     BigDecimal(rand(100..200)),
                        price:      BigDecimal(1)} }

    def create_activity!(options)
      if options[:position]
        FactoryGirl.create(:activity, options.merge(position: options[:position]))
      else
        position = Position.new(investment: options.delete(:investment))
        FactoryGirl.create(:activity, options.merge(position: position,
                                                    is_opening: true))
      end
    end

    it 'creates new position with single activity when none exists' do
      activities = GenerateActivitiesWaterfall.execute!(data)
      expect(activities.size).to eq(1)
      expect(activities[0]).to have_attributes(data)
    end

    context 'existing position with different open data' do
      let!(:existing) do
        create_activity!(investment: investment,
                         date: Date.current - 2000,
                         shares: -10,
                         price: 5)
      end

      it 'ignores positions it cannot fill' do
        existing.update(shares: 10)
        activities = GenerateActivitiesWaterfall.execute!(data)
        expect(activities.size).to eq(1)
        expect(activities[0]).to have_attributes(data)
        expect(activities[0].position).to_not eq(existing.position)
      end

      it 'ignores filled positions' do
        create_activity!(position: existing.position,
                         date: Date.current - 1999,
                         shares: 10,
                         price: 4)

        activities = GenerateActivitiesWaterfall.execute!(data)
        expect(activities.size).to eq(1)
        expect(activities[0]).to have_attributes(data)
        expect(activities[0].position).to_not eq(existing.position)
      end

      it 'fills when outstanding amount > new amount' do
        existing.update(shares: -300)

        activities = GenerateActivitiesWaterfall.execute!(data)
        expect(activities.size).to eq(1)
        expect(activities[0]).to have_attributes(data.merge position: existing.position)
      end

      it 'fills when outstanding amount == new amount' do
        existing.update(shares: -data[:shares])

        activities = GenerateActivitiesWaterfall.execute!(data)
        expect(activities.size).to eq(1)
        expect(activities[0]).to have_attributes(data.merge position: existing.position)
      end

      it 'fills up and creates new position with remainder' do
        activities = GenerateActivitiesWaterfall.execute!(data)
        expect(activities.size).to eq(2)
        expect(activities[0]).to have_attributes(position: existing.position,
                                                 date: data[:date],
                                                 shares: -existing.shares,
                                                 price: 1)
        expect(activities[1].position).to_not eq(existing.position)
        expect(activities[1]).to have_attributes(date: data[:date],
                                                 shares: data[:shares] + existing.shares,
                                                 price: 1)
      end
    end

    context 'existing positions' do
      let!(:existing) {[
        create_activity!(investment: investment,
                         date: Date.current - 2000,
                         shares: -10,
                         price: 4),
        create_activity!(investment: investment,
                         date: Date.current - 2000,
                         shares: -300,
                         price: 3),
      ]}

      it 'fills up first based on highest price' do
        activities = GenerateActivitiesWaterfall.execute!(data)
        expect(activities.size).to eq(2)
        expect(activities[0]).to have_attributes(position: existing[0].position,
                                                 date: data[:date],
                                                 shares: -existing[0].shares,
                                                 price: data[:price])
        expect(activities[1]).to have_attributes(position: existing[1].position,
                                                 date: data[:date],
                                                 shares: data[:shares] + existing[0].shares,
                                                 price: data[:price])
      end

      it 'fills up all positions before creating new position' do
        existing[1].update(shares: -20)

        activities = GenerateActivitiesWaterfall.execute!(data)
        expect(activities.size).to eq(3)
        expect(activities[0]).to have_attributes(position: existing[0].position,
                                                 date: data[:date],
                                                 shares: -existing[0].shares,
                                                 price: data[:price])
        expect(activities[1]).to have_attributes(position: existing[1].position,
                                                 date: data[:date],
                                                 shares: -existing[1].shares,
                                                 price: data[:price])
        expect(activities[2].position).to_not eq(existing[0].position)
        expect(activities[2].position).to_not eq(existing[1].position)
        expect(activities[2]).to have_attributes(date: data[:date],
                                                 shares: data[:shares] + existing.sum(&:shares),
                                                 price: data[:price])
      end
    end

    describe 'adjustments' do
      it 'ignores adjustment if == nil' do
        data[:adjustment] = nil
        activities = GenerateActivitiesWaterfall.execute!(data)
        expect(activities[0].adjustments).to be_blank
      end

      it 'ignores adjustment if == 1' do
        data[:adjustment] = 1
        activities = GenerateActivitiesWaterfall.execute!(data)
        expect(activities[0].adjustments).to be_blank
      end

      it 'creates an adjustment for the activity date' do
        data[:adjustment] = 0.5
        activities = GenerateActivitiesWaterfall.execute!(data)
        expect(activities[0].adjustments.size).to eq(1)
        expect(activities[0].adjustments[0]).to have_attributes(date: data[:date],
                                                                ratio: data[:adjustment])
      end

      context 'multiple activities' do
        before do
          data[:adjustment] = 2
          create_activity!(investment: investment,
                           date: data[:date] - 1,
                           shares: -10,
                           price: data[:price])
        end

        it 'uses the same adjustment' do
          activities = GenerateActivitiesWaterfall.execute!(data)

          expect(activities.size).to be > 1
          activities.each do |activity|
            expect(activity.adjustments).to eq([activities[0].adjustments[0]])
          end
        end
      end
    end
  end
end
