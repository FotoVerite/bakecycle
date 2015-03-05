class Product < ActiveRecord::Base
  extend AlphabeticalOrder

  belongs_to :inclusion, class_name: 'Recipe'
  belongs_to :motherdough, class_name: 'Recipe'
  belongs_to :bakery

  has_many :price_varients

  accepts_nested_attributes_for :price_varients, allow_destroy: true, reject_if: :reject_price_varients

  PRODUCT_TYPE_OPTIONS = [
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

  UNIT_OPTIONS = [:oz, :lb, :g, :kg]

  enum product_type: PRODUCT_TYPE_OPTIONS
  enum unit: UNIT_OPTIONS

  validates :name, presence: true, uniqueness: { scope: :bakery }
  validates :product_type, presence: true
  validates :description, length: { maximum: 500 }
  validates :weight, format: { with: /\A\d+(?:\.\d{0,3})?\z/ }, numericality: true
  validates :extra_amount, format: { with: /\A\d+(?:\.\d{0,3})?\z/ }, numericality: true
  validates :base_price, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: true, presence: true
  validates :bakery, presence: true

  def reject_price_varients(attributed)
    attributed['quantity'].blank? && (attributed['price'] == '0.0' || attributed['price'].blank?)
  end

  def self.unit_options
    UNIT_OPTIONS
  end

  def self.product_type_options
    PRODUCT_TYPE_OPTIONS
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

  def lead_time
    lead = [1]
    lead << inclusion.lead_days if inclusion
    lead << motherdough.lead_days if motherdough
    lead.max
  end
end
