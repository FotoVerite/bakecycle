FactoryGirl.define do
  factory :bakery do
    sequence(:name) { |n| "#{Faker::Company.name} #{Faker::Company.suffix} #{n}" }
  end
end
