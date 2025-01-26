FactoryBot.define do
  factory :user_state do
    state { Faker::Lorem.word }
    association :user
  end
end
