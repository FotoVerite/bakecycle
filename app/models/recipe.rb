# == Schema Information
#
# Table name: recipes
#
#  id              :integer          not null, primary key
#  name            :string
#  note            :text
#  mix_size        :decimal(, )
#  mix_size_unit   :integer
#  recipe_type     :integer
#  lead_days       :integer          default(0), not null
#  created_at      :datetime
#  updated_at      :datetime
#  bakery_id       :integer          not null
#  legacy_id       :string
#  total_lead_days :integer          not null
#

class Recipe < ActiveRecord::Base
  extend AlphabeticalOrder
  include ResqueJobs
  has_paper_trail

  belongs_to :bakery
  has_many :parent_recipe_items, class_name: "RecipeItem", as: :inclusionable
  has_many :parent_recipes, through: :parent_recipe_items, source: :recipe
  has_many :recipe_items, -> { where(removed: false) }, dependent: :destroy
  has_many :recipe_items_with_removes, dependent: :destroy, class_name: "RecipeItem"
  has_many :child_recipes, -> { where('recipe_items.removed': false) }, through: :recipe_items, source: :inclusionable, source_type: "Recipe"
  has_many :ingredients, -> { where('recipe_items.removed': false) }, through: :recipe_items, source: :inclusionable, source_type: "Ingredient"

  accepts_nested_attributes_for :recipe_items, allow_destroy: true, reject_if: :reject_recipe_items

  enum recipe_type: [:dough, :preferment, :inclusion]
  enum mix_size_unit: [:oz, :lb, :g, :kg]

  validates :name, presence: true, length: { maximum: 150 }, uniqueness: { scope: :bakery }
  validates :lead_days, presence: true
  validates :mix_size, numericality: true, allow_nil: true
  validates :mix_size_unit, presence: true, unless: "mix_size.blank?"
  validates :recipe_type, presence: true
  validates :note, length: { maximum: 500 }
  validates :lead_days, numericality: true
  validates :bakery, presence: true
  validate :inclusionable_a_recipe?, unless: :motherdough?

  before_save :set_recipe_lead_days
  before_save :set_total_lead_days
  before_destroy :check_for_products
  before_destroy :check_for_parent_recipes
  after_commit :queue_touch_parent_objects, on: [:create, :update]
  after_touch :update_total_lead_days

  scope :motherdoughs, -> { where(recipe_type: Recipe.recipe_types[:dough]) }
  scope :inclusions, -> { where(recipe_type: Recipe.recipe_types[:inclusion]) }
  scope :created_at_date, -> (date = Time.zone.today) { where(created_at: date.beginning_of_day..date.end_of_day) }
  scope :updated_at_date, lambda { |date = Time.zone.today|
    where(updated_at: date.beginning_of_day..date.end_of_day) }

  def self.policy_class
    ProductPolicy
  end

  def products
    Product.where("motherdough_id = :id OR inclusion_id = :id", id: id)
  end

  def items
    recipe_items.order("sort_id asc")
  end

  def update_total_lead_days
    update_columns(total_lead_days: calculate_total_lead_days)
    queue_touch_parent_objects
  end

  def set_total_lead_days
    self.total_lead_days = calculate_total_lead_days
  end

  def queue_touch_parent_objects
    async(:touch_parent_objects)
  end

  def touch_parent_objects
    parent_recipes.each(&:touch)
    products.each(&:touch)
  end

  def reject_recipe_items(attributes)
    attributes["inclusionable_id_type"].blank?
  end

  def calculate_total_lead_days
    lead_days + (child_recipes.maximum(:total_lead_days) || 0)
  end

  def set_recipe_lead_days
    return self.lead_days = 0 if inclusion?
    self.lead_days = 1 if preferment?
  end

  def inclusionable_a_recipe?
    recipe_items.each do |recipe_item|
      if recipe_item.inclusionable_type == "Recipe"
        errors.add(:recipe, "with #{recipe_type} recipe type can only include specified ingredients")
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

  private

  def check_for_products
    return unless products.any?
    errors.add(:base, I18n.t(:recipe_in_use_products))
    false
  end

  def check_for_parent_recipes
    return unless parent_recipes.any?
    errors.add(:base, I18n.t(:recipe_in_use_recipies))
    false
  end

  def motherdough?
    recipe_type == "dough"
  end

  def preferment?
    recipe_type == "preferment"
  end

  def inclusion?
    recipe_type == "inclusion"
  end
end
