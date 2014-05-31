FactoryGirl.define do
  factory :position do
    investment

    after(:create) do |position, evaluator|
      if position.activities.count == 0
        FactoryGirl.create(:activity, position: position,
                                      is_opening: true)
      end
    end
  end
end
