class Ingredient < ActiveRecord::Base
  extend AlphabeticalOrder

  has_many :recipe_parts, as: :inclusionable, class_name: 'RecipeItem'

  belongs_to :bakery

  enum unit: [:oz, :lb, :g, :kg]
  enum ingredient_type: [:flour, :ingredient]

  validates :name, presence: true, length: { maximum: 150 }, uniqueness: { scope: :bakery }
  validates :price, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: true
  validates :measure, format: { with: /\A\d+(?:\.\d{0,3})?\z/ }, numericality: true
  validates :unit, presence: true
  validates :description, length: { maximum: 500 }
  validates :ingredient_type, presence: true
  validates :bakery, presence: true

  def self.units_select
    units.keys.map { |keys| [keys.humanize(capitalize: false), keys] }
  end

  def self.ingredient_types_select
    ingredient_types.keys.map { |keys| [keys.humanize(capitalize: false), keys] }
  end
end
