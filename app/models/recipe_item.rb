class RecipeItem < ActiveRecord::Base
  belongs_to :inclusionable, polymorphic: true

  validates :bakers_percentage, presence: true
  validates :inclusionable_id_type, presence: true
  validates :bakers_percentage, format: { with: /\A\d+(?:\.\d{0,4})?\z/ }, numericality: { greater_than: 0 }
  validate :no_infinite_loops
  delegate :total_lead_days, to: :inclusionable, allow_nil: true

  scope :recipes, -> { where(inclusionable_type: 'Recipe') }

  def no_infinite_loops
    errors.add(:inclusionable_id_type, 'A recipe cannot include itself') if infinite_loop?
  end

  def infinite_loop?
    is_inclusionable_recipe = inclusionable_type && inclusionable_type.to_sym == :Recipe
    inclusionable_id && inclusionable_id == recipe_id && is_inclusionable_recipe
  end

  def self.max_lead_days
    recipes.map(&:total_lead_days).max || 0
  end

  def inclusionable_id_type=(composit_id)
    self.inclusionable_id, self.inclusionable_type = composit_id.split('-')
  end

  def inclusionable_id_type
    "#{inclusionable_id}-#{inclusionable_type}" if inclusionable
  end
end
