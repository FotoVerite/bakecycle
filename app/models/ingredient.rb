class Ingredient < ActiveRecord::Base
  has_many :recipe_parts, as: :inclusionable, class_name: "RecipeItem"
  UNIT_OPTIONS = [:oz, :lb, :g, :kg]
  INGREDIENT_TYPE_OPTIONS = [:flour, :ingredient]

  enum unit: UNIT_OPTIONS
  enum ingredient_type: INGREDIENT_TYPE_OPTIONS

  validates :name, presence: true, uniqueness: true, length: { maximum: 150 }
  validates :price, format: { with: /\A\d+(?:\.\d{0,2})?\z/}, numericality: true
  validates :measure, format: { with: /\A\d+(?:\.\d{0,3})?\z/ }, numericality: true
  validates :description, length: { maximum: 500 }
  validates :unit, presence: true
  validates :ingredient_type, presence: true

  def self.unit_options
    UNIT_OPTIONS
  end

  def self.ingredient_type_options
    INGREDIENT_TYPE_OPTIONS
  end
end
