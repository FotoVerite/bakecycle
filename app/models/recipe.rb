class Recipe < ActiveRecord::Base
  extend AlphabeticalOrder

  belongs_to :bakery
  has_many :parent_recipe_items, class_name: 'RecipeItem', as: :inclusionable
  has_many :parent_recipes, through: :parent_recipe_items, source: :recipe
  has_many :recipe_items, dependent: :destroy
  has_many :child_recipes, through: :recipe_items, source: :inclusionable, source_type: 'Recipe'

  accepts_nested_attributes_for :recipe_items, allow_destroy: true, reject_if: :reject_recipe_items

  enum recipe_type: [:dough, :preferment, :inclusion, :ingredient]
  enum mix_size_unit: [:oz, :lb, :g, :kg]

  validates :name, presence: true, length: { maximum: 150 }, uniqueness: { scope: :bakery }
  validates :lead_days, presence: true
  validates :mix_size, numericality: true, allow_nil: true
  validates :mix_size_unit, presence: true, unless: 'mix_size.blank?'
  validates :recipe_type, presence: true
  validates :note, length: { maximum: 500 }
  validates :lead_days, numericality: true
  validates :bakery, presence: true
  validate :inclusionable_a_recipe?, if: :inclusion?

  before_save :make_lead_days_zero_if_inclusion

  scope :motherdoughs, -> { where(recipe_type: Recipe.recipe_types[:dough]) }
  scope :inclusions, -> { where(recipe_type: Recipe.recipe_types[:inclusion]) }

  def products
    Product.where('motherdough_id = :id OR inclusion_id = :id', id: id)
  end

  def reject_recipe_items(attributes)
    attributes['inclusionable_id_type'].blank?
  end

  def total_lead_days
    lead_days + (child_recipes.map(&:total_lead_days).max || 0)
  end

  def make_lead_days_zero_if_inclusion
    self.lead_days = 0 if inclusion?
  end

  def inclusion?
    recipe_type == 'inclusion'
  end

  def inclusionable_a_recipe?
    recipe_items.each do |recipe_item|
      if recipe_item.inclusionable_type == 'Recipe'
        errors.add(:recipe_items, 'Inclusion recipes can only include ingredients')
      end
    end
  end

  def total_bakers_percentage
    recipe_items.map(&:bakers_percentage).sum || 0
  end

  def mix_size_with_unit
    return Unitwise(0, :kg) unless mix_size
    Unitwise(mix_size, mix_size_unit)
  end
end
