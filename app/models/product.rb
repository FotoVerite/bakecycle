class Product < ActiveRecord::Base
  belongs_to :inclusion, class_name: "Recipe"
  belongs_to :motherdough, class_name: "Recipe"
  has_many :price_varients
  accepts_nested_attributes_for :price_varients, allow_destroy: true

  PRODUCT_TYPE_OPTIONS = [:bread, :vienoisserie, :cookie, :tart, :quiche, :sandwich, :pot_pie, :dry_goods, :other]
  UNIT_OPTIONS = [:oz, :lb, :g, :kg]

  enum product_type: PRODUCT_TYPE_OPTIONS
  enum unit: UNIT_OPTIONS

  validates :name, presence: true, uniqueness: true
  validates :product_type, presence: true
  validates :description, length: { maximum: 500 }
  validates :weight, format: { with: /\A\d+(?:\.\d{0,3})?\z/ }, numericality: true
  validates :extra_amount, format: { with: /\A\d+(?:\.\d{0,3})?\z/ }, numericality: true
  validates :base_price, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: true, presence: true

  def self.unit_options
    UNIT_OPTIONS
  end

  def self.product_type_options
    PRODUCT_TYPE_OPTIONS
  end

  def price(quantity)
    return base_price if find_varients.empty?
    return base_price if quantity_varient(quantity).empty?
    quantity_varient(quantity).last.price
  end

  def find_varients
    price_varients
  end

  def effective_date_varient
    find_varients.where("effective_date <= ?", Date.today).order(:effective_date)
  end

  def quantity_varient(quantity)
    effective_date_varient.where("quantity <= ?", quantity).order(:quantity)
  end

  def save(*args)
    super
  rescue ActiveRecord::RecordNotUnique
    errors[:base] << "Identical date and quantity already exist for this product, try a different date."
    false
  end
end
