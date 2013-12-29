FactoryGirl.define do
  factory :investment do
    symbol { SecureRandom.base64.gsub(/[0-9]*/, '')[0, rand(1..4)].upcase }
    name   { Faker::Company.name }
  end
end
