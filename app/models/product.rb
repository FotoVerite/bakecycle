class Product < ActiveRecord::Base
  extend AlphabeticalOrder

  belongs_to :inclusion, class_name: 'Recipe'
  belongs_to :motherdough, class_name: 'Recipe'
  belongs_to :bakery

  has_many :price_varients

  accepts_nested_attributes_for :price_varients, allow_destroy: true, reject_if: :reject_price_varients

  enum product_type: [
    :bread,
    :vienoisserie,
    :cookie,
    :tart_and_desert,
    :quiche,
    :sandwich_and_tartine,
    :pot_pie,
    :dry_goods,
    :other
  ]

  enum unit: [:oz, :lb, :g, :kg]

  validates :name, presence: true, uniqueness: { scope: :bakery }
  validates :product_type, presence: true
  validates :description, length: { maximum: 500 }
  validates :weight, format: { with: /\A\d+(?:\.\d{0,3})?\z/ }, numericality: true
  validates :over_bake, format: { with: /\A\d+(?:\.\d{0,3})?\z/ }, numericality: true
  validates :base_price, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: true, presence: true
  validates :bakery, presence: true

  def reject_price_varients(attributed)
    attributed['quantity'].blank? && (attributed['price'] == '0.0' || attributed['price'].blank?)
  end

  def self.units_select
    units.keys.to_a.map { |keys| [keys.humanize(capitalize: false), keys] }
  end

  def self.product_types_select
    product_types.keys.to_a.map { |keys| [keys.humanize(capitalize: false), keys] }
  end

  def save(*args)
    super
  rescue ActiveRecord::RecordNotUnique
    errors[:base] << 'Quantity must be unique'
    false
  end

  def price(quantity)
    return base_price if find_varients.empty?
    return base_price if quantity_varient(quantity).empty?
    quantity_varient(quantity).last.price
  end

  def find_varients
    price_varients
  end

  def quantity_varient(quantity)
    find_varients.where('quantity <= ?', quantity).order(:quantity)
  end

  def total_lead_days
    [1, inclusion.try(:total_lead_days), motherdough.try(:total_lead_days)].compact.max
  end
end
