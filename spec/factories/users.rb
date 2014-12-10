FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "#{n}#{Faker::Lorem.word}" }
    sequence(:email) { |n| "#{n}#{Faker::Internet.email}" }
    password                'foobarbaz'
    password_confirmation   'foobarbaz'
  end
end
