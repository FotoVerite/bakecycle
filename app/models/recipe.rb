class Recipe < ActiveRecord::Base
  extend AlphabeticalOrder

  has_many :recipe_items, dependent: :destroy
  has_many :recipe_parts, as: :inclusionable, class_name: "RecipeItem"
  has_many :product

  belongs_to :bakery

  accepts_nested_attributes_for :recipe_items, allow_destroy: true

  RECIPE_TYPE_OPTIONS = [:dough, :pre_ferment, :inclusion, :ingredient]
  MIX_SIZE_UNIT_OPTIONS = [:oz, :lb, :g, :kg]

  enum recipe_type: RECIPE_TYPE_OPTIONS
  enum mix_size_unit: MIX_SIZE_UNIT_OPTIONS

  validates :name, presence: true, length: { maximum: 150 }, uniqueness: { scope: :bakery }
  validates :mix_size, format: { with: /\A\d+(?:\.\d{0,3})?\z/ }, numericality: true
  validates :recipe_type, presence: true
  validates :note, length: { maximum: 500 }
  validates :lead_days, numericality: true
  validates :mix_size_unit, presence: true
  validates :bakery, presence: true

  def self.recipe_type_options
    RECIPE_TYPE_OPTIONS
  end

  def self.mix_size_unit_options
    MIX_SIZE_UNIT_OPTIONS
  end

  def self.recipe_types_select
    recipe_types.keys.to_a.map { |keys| [keys.humanize(capitalize: false), keys] }
  end

  def self.mix_size_units_select
    mix_size_units.keys.to_a.map { |keys| [keys.humanize(capitalize: false), keys] }
  end

  def self.motherdoughs
    where("recipe_type = ?", Recipe.recipe_types[:dough])
  end

  def self.inclusions
    where("recipe_type = ?", Recipe.recipe_types[:inclusion])
  end
end
