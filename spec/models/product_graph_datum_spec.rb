# == Schema Information
#
# Table name: product_graph_data
#
#  id             :integer          not null, primary key
#  product_id     :integer
#  bakery_id      :integer
#  date           :date
#  shipment_count :integer
#  shipped        :integer
#  amount         :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require "rails_helper"

RSpec.describe ProductGraphDatum, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
