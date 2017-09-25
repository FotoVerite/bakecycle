# == Schema Information
#
# Table name: ingredients
#
#  id              :integer          not null, primary key
#  name            :string
#  description     :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  bakery_id       :integer          not null
#  legacy_id       :string
#  ingredient_type :string           default("other"), not null
#  vendor_id       :integer
#  cost            :decimal(, )      default(0.0), not null
#  current_amount  :decimal(, )      default(0.0), not null
#  weight_unit     :string
#  conversion      :decimal(, )      default(0.0)
#

class IngredientSerializer < ActiveModel::Serializer
  attributes :id, :name, :ingredient_type, :current_amount, :vendor_id, :cost
  has_many :recipe_items
end
