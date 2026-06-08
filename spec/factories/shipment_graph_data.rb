# frozen_string_literal: true

# == Schema Information
#
# Table name: shipment_graph_data
#
#  id            :integer          not null, primary key
#  bakery_id     :integer
#  product_count :integer
#  amount        :decimal(, )      default(0.0), not null
#  date          :date
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryBot.define do
  factory :shipment_graph_datum do
  end
end
