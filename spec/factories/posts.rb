FactoryBot.define do
  factory :post do
    body { Faker::Lorem.sentence }
    association :user

    after(:build) do |post|
      post.image.attach(
        io: File.open(Rails.root.join('spec/fixtures/test_image.jpg')),
        filename: 'test_image.jpg',
        content_type: 'image/jpeg'
      )
    end
  end
end
