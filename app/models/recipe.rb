class Recipe < ActiveRecord::Base
  has_many :recipe_items, dependent: :destroy, inverse_of: :recipe
  has_many :recipe_parts, as: :inclusionable, class_name: "RecipeItem"
  has_many :product
  accepts_nested_attributes_for :recipe_items, allow_destroy: true

  RECIPE_TYPE_OPTIONS = [:dough, :pre_ferment, :inclusion, :ingredient]
  MIX_SIZE_UNIT_OPTIONS = [:oz, :lb, :g, :kg]

  enum recipe_type: RECIPE_TYPE_OPTIONS
  enum mix_size_unit: MIX_SIZE_UNIT_OPTIONS

  validates :name, presence: true, uniqueness: true, length: { maximum: 150 }
  validates :mix_size, format: { with: /\A\d+(?:\.\d{0,3})?\z/ }, numericality: true
  validates :note, length: { maximum: 500 }
  validates :lead_days, numericality: true
  validates :mix_size_unit, presence: true

  def self.recipe_type_options
    RECIPE_TYPE_OPTIONS
  end

  def self.mix_size_unit_options
    MIX_SIZE_UNIT_OPTIONS
  end

  def self.motherdoughs
    where("recipe_type = ?", Recipe.recipe_types[:dough])
  end

  def self.inclusions
    where("recipe_type = ?", Recipe.recipe_types[:inclusion])
  end
end
