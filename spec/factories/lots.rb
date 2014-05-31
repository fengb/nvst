FactoryGirl.define do
  factory :lot do
    investment

    after(:create) do |lot, evaluator|
      if lot.activities.count == 0
        FactoryGirl.create(:activity, lot: lot, is_opening: true)
      end
    end
  end
end
