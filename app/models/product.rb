# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  product_type    :integer          not null
#  weight          :decimal(, )      not null
#  unit            :integer          not null
#  description     :text
#  over_bake       :decimal(, )      default(0.0), not null
#  motherdough_id  :integer
#  inclusion_id    :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  base_price      :decimal(, )      not null
#  bakery_id       :integer          not null
#  sku             :string
#  legacy_id       :string
#  total_lead_days :integer          not null
#  batch_recipe    :boolean          default(FALSE)
#  removed         :boolean          default(FALSE)
#  graph_data      :json
#  pieces_per_tray :integer
#

class Product < ApplicationRecord
  extend AlphabeticalOrder
  include AsyncJobs
  has_paper_trail ignore: [:graph_data]

  belongs_to :inclusion, class_name: "Recipe", inverse_of: :inclusion_products, optional: true
  belongs_to :motherdough, class_name: "Recipe", inverse_of: :motherdough_products, optional: true
  belongs_to :bakery

  has_many :shipment_items, dependent: :nullify

  has_many :run_items, dependent: :nullify

  has_many :price_variants, -> { where(removed: false) }, dependent: :destroy, inverse_of: :product
  has_many :price_variants_with_removes, dependent: :destroy, class_name: "PriceVariant", inverse_of: :product

  accepts_nested_attributes_for :price_variants, allow_destroy: true, reject_if: :reject_price_variants?

  enum :product_type, {
    bread: 10,
    cookie: 11,
    pot_pie: 12,
    quiche: 13,
    sandwich_and_tartine: 14,
    tart_and_desert: 15,
    vienoisserie: 16,
    dry_goods: 17,
    wholesale_sandwiches: 19,
    other: 18
  }

  enum :unit, { oz: 0, lb: 1, g: 2, kg: 3 }

  validates :bakery, presence: true
  validates :name, presence: true, uniqueness: { scope: :bakery_id }
  validates :product_type, presence: true
  validates :weight, presence: true, numericality: true
  validates :unit, presence: true
  validates :over_bake, presence: true, numericality: true
  validates :base_price, presence: true, numericality: true
  validates :description, length: { maximum: 500 }
  validates :pieces_per_tray, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :check_for_order_items

  before_validation :strip_name
  before_save :set_total_lead_days, if: :update_total_lead_days?
  after_commit :queue_touch_order_items, on: %i[create update], if: :lead_days_relevant_change?
  after_touch :update_total_lead_days
  before_destroy :check_for_order_items, prepend: true

  scope :created_at_date, ->(date = Time.zone.today) { where(created_at: date.beginning_of_day..date.end_of_day) }
  scope :updated_at_date, lambda { |date = Time.zone.today|
    where(updated_at: date.beginning_of_day..date.end_of_day)
  }

  scope :available, -> { where(removed: false, inactive: false) }
  scope :active, -> { where(active: true) }

  def strip_name
    self.name = name.strip if name
  end

  def update_total_lead_days
    update_columns(total_lead_days: set_total_lead_days)
    touch_order_items
  end

  def set_total_lead_days
    lead_days = [lead_days_override, inclusion.try(:total_lead_days), motherdough.try(:total_lead_days)].compact.max
    self.total_lead_days = lead_days
  end

  def update_total_lead_days?
    new_record? || motherdough_id_changed? || inclusion_id_changed? || lead_days_override_changed?
  end

  # Touching every order item for this product (and thus PaperTrail-versioning
  # them) is only meaningful when total_lead_days could have changed -- not on
  # every unrelated product edit (name, price, etc).
  def lead_days_relevant_change?
    previously_new_record? || saved_change_to_total_lead_days? ||
      saved_change_to_motherdough_id? || saved_change_to_inclusion_id? || saved_change_to_lead_days_override?
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
    lookup_price_variant(quantity, client) || base_price
  end

  def weight_with_unit
    Unitwise(weight, unit)
  end

  def dough_weight_with_unit
    Unitwise(product_dough_weight, unit)
  end

  def product_dough_weight
    dough_percentage * percent_weight
  end

  def product_inclusion_weight
    (inclusion_percentage * percent_weight)
  end

  def destroy
    unless inactive
      errors.add(:base, "product must first be set to inactive!")
      return false
    end
    return false unless check_for_order_items

    self.removed = true
    save
  end

  # Returns a relation (not an Array) so callers can paginate/count in the database
  # instead of loading every order_item for the product into Ruby, which was the source
  # of the slowdown on products with thousands of orders.
  def orders_in_use
    Order.where(id: OrderItem.where(product_id: id).select(:order_id))
         .merge(Order.still_in_use)
         .includes(:client, :route)
  end

  def price_varient_info(client_id)
    price_variants
      .where("client_id IS NULL OR client_id = ?", client_id)
      .order(quantity: :desc)
  end

  private

  def order_items
    OrderItem.where(product_id: id)
  end

  def check_for_order_items
    return true unless inactive
    return true unless order_items.any?
    # see if any orders are still active
    return true unless orders_in_use.exists?

    errors.add(:base, I18n.t(:product_in_use))
    false
  end

  def dough_percentage
    motherdough.total_bakers_percentage
  end

  def percent_weight
    return weight if dough_percentage.zero? && inclusion_percentage.zero?

    weight / (dough_percentage + inclusion_percentage)
  end

  def inclusion_percentage
    return 0 unless inclusion

    inclusion.total_bakers_percentage
  end

  def lookup_price_variant(quantity, client)
    matching = price_variants
      .select { |variant| variant.client_id.nil? || variant.client_id == client.id }
      .sort_by { |variant| -variant.quantity }
      .detect { |variant| variant.quantity <= quantity }
    matching&.price
  end
end
