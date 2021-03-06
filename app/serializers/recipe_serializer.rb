# == Schema Information
#
# Table name: recipes
#
#  id              :integer          not null, primary key
#  name            :string
#  note            :text
#  mix_size        :decimal(, )
#  mix_size_unit   :integer
#  recipe_type     :integer
#  lead_days       :integer          default(0), not null
#  created_at      :datetime
#  updated_at      :datetime
#  bakery_id       :integer          not null
#  legacy_id       :string
#  total_lead_days :integer          not null
#

class RecipeSerializer < ActiveModel::Serializer
  attributes :id, :name, :recipe_type, :note, :mix_size, :mix_size_unit, :lead_days, :total_lead_days,
   :available_inclusions, :available_recipe_ingredients, :recipe_types, :mix_units,
   :errors
  has_many :recipe_items

  def recipe_items
    object.recipe_items.order("sort_id asc").includes(:inclusionable)
  end

  def recipe_type
    object.recipe_type || ""
  end

  def available_inclusions
    object.decorate.available_inclusions.unshift(["Select One", ""])
  end

  def available_recipe_ingredients
    object.decorate.available_ingredients.unshift(["Select One", ""])
  end

  def recipe_types
    object.decorate.recipe_types_select
  end

  def mix_units
    object.decorate.mix_size_units_select
  end
end
