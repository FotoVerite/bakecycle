# == Schema Information
#
# Table name: ingredient_prices_over_times
#
#  id            :integer          not null, primary key
#  ingredient_id :integer
#  vendor_id     :integer
#  bakery_id     :integer
#  weight_unit   :string
#  conversion    :decimal(, )
#  cost_per_unit :decimal(, )
#  cost_per_gram :decimal(, )
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require "rails_helper"

RSpec.describe IngredientPricesOverTime, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
