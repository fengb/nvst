FactoryBot.define do
  factory :position do
    investment

    transient do
      opening_activity { nil }
    end

    after(:create) do |position, evaluator|
      if position.activities.count == 0 || evaluator.opening_activity
        args = {position: position, is_opening: true}
        args.merge!(evaluator.opening_activity) if evaluator.opening_activity
        FactoryBot.create(:activity, args)
      end
    end
  end
end
