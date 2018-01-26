# == Schema Information
#
# Table name: shipments
#
#  id                               :integer          not null, primary key
#  client_id                        :integer          not null
#  route_id                         :integer          not null
#  date                             :date             not null
#  payment_due_date                 :date             not null
#  bakery_id                        :integer          not null
#  delivery_fee                     :decimal(, )      default(0.0), not null
#  auto_generated                   :boolean          default(FALSE), not null
#  client_name                      :string           not null
#  client_official_company_name     :string
#  client_billing_term              :string           not null
#  client_delivery_address_street_1 :string
#  client_delivery_address_street_2 :string
#  client_delivery_address_city     :string
#  client_delivery_address_state    :string
#  client_delivery_address_zipcode  :string
#  client_billing_address_street_1  :string
#  client_billing_address_street_2  :string
#  client_billing_address_city      :string
#  client_billing_address_state     :string
#  client_billing_address_zipcode   :string
#  client_billing_term_days         :integer          not null
#  route_name                       :string           not null
#  note                             :text
#  client_primary_contact_name      :string
#  client_primary_contact_phone     :string
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  route_departure_time             :time             not null
#  client_notes                     :string
#  order_id                         :integer
#  sequence_number                  :integer
#  alert                            :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :shipment do
    date  { Time.zone.today + Faker::Number.number(1).to_i.days }
    bakery
    route { |t| t.association(:route, bakery: bakery) }
    client { |t| t.association(:client, bakery: bakery) }
    note { Faker::Lorem.sentence(1) }

    transient do
      shipment_item_count 1
      total_lead_days 2
      product { |t| t.association(:product, :with_motherdough, bakery: bakery, total_lead_days: total_lead_days) }
    end

    shipment_items do |t|
      Array.new(shipment_item_count) do
        t.association(
          :shipment_item,
          shipment: t.instance_variable_get(:@instance),
          product: product,
          bakery: bakery
        )
      end
    end

    trait :with_delivery_fee do
      delivery_fee { Faker::Number.decimal(2) }
    end
  end
end
