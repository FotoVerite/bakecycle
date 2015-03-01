class Ingredient < ActiveRecord::Base
  extend AlphabeticalOrder

  has_many :recipe_parts, as: :inclusionable, class_name: 'RecipeItem'

  belongs_to :bakery

  UNIT_OPTIONS = [:oz, :lb, :g, :kg]
  INGREDIENT_TYPE_OPTIONS = [:flour, :ingredient]

  enum unit: UNIT_OPTIONS
  enum ingredient_type: INGREDIENT_TYPE_OPTIONS

  validates :name, presence: true, length: { maximum: 150 }, uniqueness: { scope: :bakery }
  validates :price, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: true
  validates :measure, format: { with: /\A\d+(?:\.\d{0,3})?\z/ }, numericality: true
  validates :description, length: { maximum: 500 }
  validates :unit, presence: true
  validates :ingredient_type, presence: true
  validates :bakery, presence: true

  def self.unit_options
    UNIT_OPTIONS
  end

  def self.ingredient_type_options
    INGREDIENT_TYPE_OPTIONS
  end

  def self.units_select
    units.keys.to_a.map { |keys| [keys.humanize(capitalize: false), keys] }
  end

  def self.ingredient_types_select
    ingredient_types.keys.to_a.map { |keys| [keys.humanize(capitalize: false), keys] }
  end
end
