FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "#{Faker::Name.name} #{n}" }
    sequence(:email) { |n| "#{n}#{Faker::Internet.email}" }
    password                'foobarbaz'
    password_confirmation   'foobarbaz'
    admin false
    bakery
    user_permission 'manage'

    trait :as_admin do
      admin true
      user_permission 'manage'
    end
  end
end
