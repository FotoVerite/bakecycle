# frozen_string_literal: true

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

class ProductGraphDatum < ApplicationRecord
end
