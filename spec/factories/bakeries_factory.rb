FactoryGirl.define do
  factory :bakery do
    sequence(:name) { |n| "#{Faker::Company.name} #{Faker::Company.suffix} #{n}" }
    email { Faker::Internet.email }
    phone_number { Faker::PhoneNumber.cell_phone }
    address_street_1 { Faker::Address.street_address }
    address_city { Faker::Address.city }
    address_state { Faker::Address.state }
    address_zipcode { Faker::Address.zip_code }
    logo { File.new(File.join(Rails.root, 'app/assets/images/example_logo.png')) }
  end
end
