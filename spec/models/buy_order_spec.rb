# == Schema Information
#
# Table name: buy_orders
#
#  id            :integer          not null, primary key
#  vendor_id     :integer
#  ingredient_id :integer
#  bakery_id     :integer
#  amount        :decimal(, )      default(0.0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require "rails_helper"

RSpec.describe BuyOrder, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
