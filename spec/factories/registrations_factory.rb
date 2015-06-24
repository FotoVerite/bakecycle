FactoryGirl.define do
  factory :registration do
    sequence(:first_name) { Faker::Name.name }
    sequence(:last_name) { Faker::Name.name }
    sequence(:email) { |n| "#{n}#{Faker::Internet.email}" }
    sequence(:bakery_name) { |n| "#{Faker::Name.name} #{n}" }
    password 'foobarbaz'
    plan
  end
end
