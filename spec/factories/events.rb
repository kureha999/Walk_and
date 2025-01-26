FactoryBot.define do
  factory :event do
    title { Faker::Lorem.word }
    time { Time.now }
    event_type { :walk }
    association :user
  end
end
