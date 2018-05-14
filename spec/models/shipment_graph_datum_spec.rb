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

require "rails_helper"

RSpec.describe ShipmentGraphDatum, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
