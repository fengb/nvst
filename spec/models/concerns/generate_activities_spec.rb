require 'spec_helper'


describe GenerateActivities do
  describe '#generate_activities!' do
    class TestClass < OpenStruct
      include GenerateActivities
    end

    subject { TestClass.new(activities: [], raw_activities_data: []) }

    context 'already has activities' do
      before { subject.activities = [1] }

      it 'returns nil' do
        expect(subject.generate_activities!).to be(nil)
      end

      it 'does absolutely nothing' do
        expect(GenerateActivities).to_not receive(:execute!)
        subject.generate_activities!
      end
    end

    it 'passes raw activity data to GenerateActivities.execute!' do
      subject.raw_activities_data = [4, 2, 5]
      expect(GenerateActivities).to receive(:execute!).with(4).and_return([4])
      expect(GenerateActivities).to receive(:execute!).with(2).and_return([2])
      expect(GenerateActivities).to receive(:execute!).with(5).and_return([5])

      subject.generate_activities!
    end

    it 'adds GenerateActivities.execute! returned values to activities' do
      subject.raw_activities_data = [:a, :z]
      allow(GenerateActivities).to receive_messages(execute!: [1, 2])

      subject.generate_activities!
      expect(subject.activities).to eq([1, 2, 1, 2])
    end
  end

  describe '.execute!' do
    let(:investment) { FactoryGirl.create(:investment) }
    let(:data)       { {investment: investment,
                        date:       Date.today - rand(1000),
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
      activities = GenerateActivities.execute!(data)
      expect(activities.size).to eq(1)
      expect_data(activities[0], data)
    end

    context 'corresponding position' do
      let(:existing) do
        create_activity!(investment: investment,
                         date: data[:date],
                         shares: -10,
                         price: data[:price])
      end

      before do
        allow(Position).to receive_messages(corresponding: existing.position)
      end

      it 'reuses the position' do
        activities = GenerateActivities.execute!(data)
        expect(activities.size).to eq(1)
        expect_data(activities[0], data, position: existing.position)
      end
    end

    context 'existing position with different open data' do
      let!(:existing) do
        create_activity!(investment: investment,
                         date: Date.today - 2000,
                         shares: -10,
                         price: 5)
      end

      it 'ignores positions it cannot fill' do
        existing.update(shares: 10)
        activities = GenerateActivities.execute!(data)
        expect(activities.size).to eq(1)
        expect_data(activities[0], data)
        expect(activities[0].position).to_not eq(existing.position)
      end

      it 'ignores filled positions' do
        create_activity!(position: existing.position,
                         date: Date.today - 1999,
                         shares: 10,
                         price: 4)

        activities = GenerateActivities.execute!(data)
        expect(activities.size).to eq(1)
        expect_data(activities[0], data)
        expect(activities[0].position).to_not eq(existing.position)
      end

      it 'fills when outstanding amount > new amount' do
        existing.update(shares: -300)

        activities = GenerateActivities.execute!(data)
        expect(activities.size).to eq(1)
        expect_data(activities[0], data, position: existing.position)
      end

      it 'fills when outstanding amount == new amount' do
        existing.update(shares: -data[:shares])

        activities = GenerateActivities.execute!(data)
        expect(activities.size).to eq(1)
        expect_data(activities[0], data, position: existing.position)
      end

      it 'fills up and creates new position with remainder' do
        activities = GenerateActivities.execute!(data)
        expect(activities.size).to eq(2)
        expect_data(activities[0], position: existing.position,
                                   date: data[:date],
                                   shares: -existing.shares,
                                   price: 1)
        expect(activities[1].position).to_not eq(existing.position)
        expect_data(activities[1], date: data[:date],
                                   shares: data[:shares] + existing.shares,
                                   price: 1)
      end
    end

    context 'existing positions' do
      let!(:existing) {[
        create_activity!(investment: investment,
                         date: Date.today - 2000,
                         shares: -10,
                         price: 4),
        create_activity!(investment: investment,
                         date: Date.today - 2000,
                         shares: -300,
                         price: 3),
      ]}

      it 'fills up first based on highest price' do
        activities = GenerateActivities.execute!(data)
        expect(activities.size).to eq(2)
        expect_data(activities[0], position: existing[0].position,
                                   date: data[:date],
                                   shares: -existing[0].shares,
                                   price: data[:price])
        expect_data(activities[1], position: existing[1].position,
                                   date: data[:date],
                                   shares: data[:shares] + existing[0].shares,
                                   price: data[:price])
      end

      it 'fills up all positions before creating new position' do
        existing[1].update(shares: -20)

        activities = GenerateActivities.execute!(data)
        expect(activities.size).to eq(3)
        expect_data(activities[0], position: existing[0].position,
                                   date: data[:date],
                                   shares: -existing[0].shares,
                                   price: data[:price])
        expect_data(activities[1], position: existing[1].position,
                                   date: data[:date],
                                   shares: -existing[1].shares,
                                   price: data[:price])
        expect(activities[2].position).to_not eq(existing[0].position)
        expect(activities[2].position).to_not eq(existing[1].position)
        expect_data(activities[2], date: data[:date],
                                   shares: data[:shares] + existing.sum(&:shares),
                                   price: data[:price])
      end
    end

    describe 'adjustments' do
      it 'ignores adjustment if == nil' do
        data[:adjustment] = nil
        activities = GenerateActivities.execute!(data)
        expect(activities[0].adjustments).to be_blank
      end

      it 'ignores adjustment if == 1' do
        data[:adjustment] = 1
        activities = GenerateActivities.execute!(data)
        expect(activities[0].adjustments).to be_blank
      end

      it 'creates an adjustment for the activity date' do
        data[:adjustment] = 0.5
        activities = GenerateActivities.execute!(data)
        expect(activities[0].adjustments.size).to eq(1)
        expect_data(activities[0].adjustments[0], date: data[:date],
                                                  ratio: data[:adjustment])
      end

      context 'activity waterfall' do
        before do
          data[:adjustment] = 2
          create_activity!(investment: investment,
                           date: data[:date] - 1,
                           shares: -10,
                           price: data[:price])
        end

        it 'uses the same adjustment for multiple activities' do
          activities = GenerateActivities.execute!(data)

          expect(activities.size).to be > 1
          activities.each do |activity|
            expect(activity.adjustments).to eq([activities[0].adjustments[0]])
          end
        end
      end
    end
  end
end
