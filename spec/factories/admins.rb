FactoryBot.define do
  factory :admin do
    username { FFaker::Internet.user_name }
    password { 'password' }
  end
end
