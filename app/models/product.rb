class Product < ActiveRecord::Base
  extend AlphabeticalOrder
  include ResqueJobs

  belongs_to :inclusion, class_name: 'Recipe'
  belongs_to :motherdough, class_name: 'Recipe'
  belongs_to :bakery

  has_many :price_variants, dependent: :destroy

  accepts_nested_attributes_for :price_variants, allow_destroy: true, reject_if: :reject_price_variants?

  enum product_type: {
     bread: 10,
     cookie: 11,
     pot_pie: 12,
     quiche: 13,
     sandwich_and_tartine: 14,
     tart_and_desert: 15,
     vienoisserie: 16,
     dry_goods: 17,
     other: 18
  }

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
  after_commit :queue_touch_order_items, on: [:create, :update]
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

  def queue_touch_order_items
    async(:touch_order_items)
  end

  def touch_order_items
    OrderItem.where(product_id: id).find_each(&:touch)
  end

  def reject_price_variants?(attributes)
    attributes['quantity'].blank? && (attributes['price'] == '0.0' || attributes['price'].blank?)
  end

  def save(*args)
    super
  rescue ActiveRecord::RecordNotUnique
    errors[:base] << 'Quantity must be unique'
    false
  end

  def price(quantity)
    price_by_quantity(quantity) || base_price
  end

  # price variants are probably always going to be very small set, getting all of them allows the query to be cached
  def price_by_quantity(quantity)
    matching = price_variants.order('quantity desc').detect { |variant| variant.quantity <= quantity }
    matching.price if matching
  end

  def weight_with_unit
    Unitwise(weight, unit)
  end
end
