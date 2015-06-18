FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "#{Faker::Name.name} #{n}" }
    sequence(:email) { |n| "#{n}#{Faker::Internet.email}" }
    password                'foobarbaz'
    password_confirmation   'foobarbaz'
    admin false
    bakery
    user_permission 'manage'
    product_permission 'manage'
    bakery_permission 'manage'

    trait :as_admin do
      admin true
      user_permission 'none'
      product_permission 'none'
      bakery_permission 'none'
    end
  end
end
