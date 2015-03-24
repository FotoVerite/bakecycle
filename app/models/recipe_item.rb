class RecipeItem < ActiveRecord::Base
  belongs_to :inclusionable, polymorphic: true

  validates :bakers_percentage, presence: true
  validates :inclusionable_id_type, presence: true
  validates :bakers_percentage, format: { with: /\A\d+(?:\.\d{0,3})?\z/ }, numericality: { greater_than: 0.001 }

  delegate :total_lead_days, to: :inclusionable, allow_nil: true

  scope :recipes, -> { where(inclusionable_type: 'Recipe') }

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
