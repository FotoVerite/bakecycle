FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "#{n}#{Faker::Lorem.word}" }
    sequence(:email) { |n| "#{n}#{Faker::Internet.email}" }
    password                'foobarbaz'
    password_confirmation   'foobarbaz'
    admin false
    bakery

    factory :admin do
      admin true
      bakery nil
    end

    factory :admin_bakery do
      admin true
    end
  end
end
