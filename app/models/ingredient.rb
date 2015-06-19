class Ingredient < ActiveRecord::Base
  extend AlphabeticalOrder

  has_many :recipe_parts, as: :inclusionable, class_name: 'RecipeItem'

  belongs_to :bakery

  validates :name, presence: true, length: { maximum: 150 }, uniqueness: { scope: :bakery }
  validates :description, length: { maximum: 500 }
  validates :bakery, presence: true

  def self.policy_class
    ProductPolicy
  end

  def total_lead_days
    0
  end
end
