FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "#{Faker::Name.name} #{n}" }
    sequence(:email) { |n| "#{n}#{Faker::Internet.email}" }
    password                'foobarbaz'
    password_confirmation   'foobarbaz'
    admin false
    bakery

    trait :as_admin do
      admin true
    end
  end
end
