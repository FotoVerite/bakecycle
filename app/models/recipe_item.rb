class RecipeItem < ActiveRecord::Base
  belongs_to :inclusionable, polymorphic: true
  belongs_to :recipe

  validates :bakers_percentage, presence: true
  validates :bakers_percentage, numericality: { greater_than: 0 }, unless: "bakers_percentage.blank?"
  validates :inclusionable_id_type, presence: true

  validate :no_infinite_loops

  after_save :touch_recipe

  delegate :total_lead_days, to: :inclusionable, allow_nil: true

  def no_infinite_loops
    errors.add(:inclusionable_id_type, "#{inclusionable.try(:name)} recipe cannot include itself") if infinite_loop?
  end

  def infinite_loop?
    is_inclusionable_recipe = inclusionable_type && inclusionable_type.to_sym == :Recipe
    inclusionable_id && inclusionable_id == recipe_id && is_inclusionable_recipe
  end

  def inclusionable_id_type=(composit_id)
    self.inclusionable_id, self.inclusionable_type = composit_id.split("-")
  end

  def inclusionable_id_type
    "#{inclusionable_id}-#{inclusionable_type}" if inclusionable
  end

  def touch_recipe
    recipe.try(:touch)
  end
end
