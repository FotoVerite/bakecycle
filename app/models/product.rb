class Product < ActiveRecord::Base
  extend AlphabeticalOrder
  include ResqueJobs

  belongs_to :inclusion, class_name: "Recipe"
  belongs_to :motherdough, class_name: "Recipe"
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
  validates :weight, presence: true, numericality: true
  validates :unit, presence: true
  validates :over_bake, presence: true, numericality: true
  validates :base_price, presence: true, numericality: true
  validates :description, length: { maximum: 500 }

  before_validation :strip_name
  before_save :set_total_lead_days, if: :update_total_lead_days?
  after_commit :queue_touch_order_items, on: [:create, :update]
  after_touch :update_total_lead_days
  before_destroy :check_for_order_items

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
    order_items.find_each(&:touch)
  end

  def reject_price_variants?(attributes)
    attributes["quantity"].blank? && (attributes["price"] == "0.0" || attributes["price"].blank?)
  end

  def price(quantity, client)
    price_by_quantity(quantity, client) || base_price
  end

  def weight_with_unit
    Unitwise(weight, unit)
  end

  private

  def order_items
    OrderItem.where(product_id: id)
  end

  def check_for_order_items
    return unless order_items.any?
    errors.add(:base, I18n.t(:product_in_use))
    false
  end

  def price_by_quantity(quantity, client)
    matching = price_variants
      .where("client_id IS NULL OR client_id = ?", client.id)
      .order(quantity: :desc)
      .detect { |variant| variant.quantity <= quantity }
    matching.price if matching
  end
end
