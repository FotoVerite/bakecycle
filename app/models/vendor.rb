# == Schema Information
#
# Table name: vendors
#
#  id         :integer          not null, primary key
#  bakery_id  :integer
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Vendor < ApplicationRecord
  belongs_to :bakery
  has_many :ingredient_prices_over_time, dependent: :destroy

  delegate :ingredients, to: :bakery
end
