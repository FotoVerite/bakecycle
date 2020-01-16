FactoryBot.define do
  factory :public_client_user do
    first_name { Faker::Name.first_name}
    last_name { Faker::Name.last_name}
    sequence(:email) { |n| "#{n}#{Faker::Internet.email}" }

  end
end
