class Ingredient < ActiveRecord::Base
  extend AlphabeticalOrder

  INGREDIENT_TYPES = %w(flour salt yeast sugar hydration eggs fats other)

  has_many :recipe_parts, as: :inclusionable, class_name: 'RecipeItem'

  belongs_to :bakery

  validates :name, presence: true, length: { maximum: 150 }, uniqueness: { scope: :bakery }
  validates :description, length: { maximum: 500 }
  validates :ingredient_type,
            presence: true,
            inclusion: { in: INGREDIENT_TYPES }
  validates :bakery, presence: true

  def self.policy_class
    ProductPolicy
  end

  def total_lead_days
    0
  end
end
