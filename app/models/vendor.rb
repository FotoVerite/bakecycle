# frozen_string_literal: true

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
  has_many :buy_orders, dependent: :destroy

  accepts_nested_attributes_for :buy_orders, reject_if: proc { |attributes|
    attributes[:amount].blank? || attributes[:amount].to_f.zero?
  }

  delegate :ingredients, to: :bakery
end
