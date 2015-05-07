class Product < ActiveRecord::Base
  extend AlphabeticalOrder

  belongs_to :inclusion, class_name: 'Recipe'
  belongs_to :motherdough, class_name: 'Recipe'
  belongs_to :bakery

  has_many :price_varients, dependent: :destroy

  accepts_nested_attributes_for :price_varients, allow_destroy: true, reject_if: :reject_price_varients?

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

  validates :bakery, presence: true
  validates :name, presence: true, uniqueness: { scope: :bakery }
  validates :product_type, presence: true
  validates :weight, numericality: true, presence: true
  validates :unit, presence: true
  validates :over_bake, numericality: true, presence: true
  validates :base_price, numericality: true, presence: true

  before_validation :strip_name

  before_save :set_total_lead_days, if: :update_total_lead_days?

  after_save :touch_order_items

  after_touch :update_total_lead_days

  def strip_name
    self.name = name.strip if name
  end

  def update_total_lead_days
    update_columns(total_lead_days: set_total_lead_days)
    touch_order_items
  end

  def set_total_lead_days
    lead_days = [1, inclusion.try(:total_lead_days), motherdough.try(:total_lead_days)].compact.max
    self.total_lead_days = lead_days
  end

  def update_total_lead_days?
    new_record? || motherdough_id_changed? || inclusion_id_changed?
  end

  def touch_order_items
    OrderItem.where(product_id: id).find_each(&:touch)
  end

  def reject_price_varients?(attributes)
    attributes['quantity'].blank? && (attributes['price'] == '0.0' || attributes['price'].blank?)
  end

  def save(*args)
    super
  rescue ActiveRecord::RecordNotUnique
    errors[:base] << 'Quantity must be unique'
    false
  end

  def price(quantity)
    quantity_varient(quantity).try(:price) || base_price
  end

  def quantity_varient(quantity)
    price_varients.where('quantity <= ?', quantity).order('quantity desc').first
  end

  def weight_with_unit
    Unitwise(weight, unit)
  end
end
