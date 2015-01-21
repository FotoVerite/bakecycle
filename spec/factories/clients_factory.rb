FactoryGirl.define do
  factory :client do
    sequence(:name) { |n| "#{Faker::Company.name} #{Faker::Company.suffix} #{n}" }
    business_phone { Faker::PhoneNumber.cell_phone }
    active true

    delivery_address_street_1 { Faker::Address.street_address }
    delivery_address_city { Faker::Address.city }
    delivery_address_state { Faker::Address.state }
    delivery_address_zipcode { Faker::Address.zip_code }
    latitude { Faker::Address.latitude.to_f }
    longitude { Faker::Address.longitude.to_f }

    billing_address_street_1 { Faker::Address.street_address }
    billing_address_city { Faker::Address.city }
    billing_address_state { Faker::Address.state }
    billing_address_zipcode { Faker::Address.zip_code }

    accounts_payable_contact_name { Faker::Name.name }
    accounts_payable_contact_phone { Faker::PhoneNumber.cell_phone }
    accounts_payable_contact_email { Faker::Internet.email }

    primary_contact_name { Faker::Name.name }
    primary_contact_phone { Faker::PhoneNumber.cell_phone }
    primary_contact_email { Faker::Internet.email }

    billing_term { [:net_45, :net_30, :net_15, :net_7, :credit_card, :cod].sample }

    trait :with_secondary_contact do
      secondary_contact_name { Faker::Name.name }
      secondary_contact_phone { Faker::PhoneNumber.cell_phone }
      secondary_contact_email { Faker::Internet.email }
    end
  end
end
