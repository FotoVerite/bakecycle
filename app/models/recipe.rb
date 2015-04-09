class Recipe < ActiveRecord::Base
  extend AlphabeticalOrder

  has_many :recipe_items, dependent: :destroy
  has_many :recipe_parts, as: :inclusionable, class_name: 'RecipeItem'
  has_many :product

  belongs_to :bakery

  accepts_nested_attributes_for :recipe_items, allow_destroy: true, reject_if: :reject_recipe_items

  enum recipe_type: [:dough, :pre_ferment, :inclusion, :ingredient]
  enum mix_size_unit: [:oz, :lb, :g, :kg]

  validates :name, presence: true, length: { maximum: 150 }, uniqueness: { scope: :bakery }
  validates :lead_days, presence: true
  validates :mix_size, format: { with: /\A\d+(?:\.\d{0,3})?\z/ }, numericality: true, allow_nil: true
  validates :mix_size_unit, presence: true, unless: 'mix_size.blank?'
  validates :recipe_type, presence: true
  validates :note, length: { maximum: 500 }
  validates :lead_days, numericality: true
  validates :bakery, presence: true
  validate :inclusionable_a_recipe?, if: :inclusion?

  before_save :make_lead_days_zero_if_inclusion

  def reject_recipe_items(attributes)
    attributes['inclusionable_id_type'].blank?
  end

  def self.recipe_types_select
    recipe_types.keys.to_a.map { |keys| [keys.humanize(capitalize: false), keys] }
  end

  def self.mix_size_units_select
    mix_size_units.keys.to_a.map { |keys| [keys.humanize(capitalize: false), keys] }
  end

  def self.motherdoughs
    where(recipe_type: Recipe.recipe_types[:dough])
  end

  def self.inclusions
    where(recipe_type: Recipe.recipe_types[:inclusion])
  end

  def total_lead_days
    lead_days + recipe_items.max_lead_days
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
end
