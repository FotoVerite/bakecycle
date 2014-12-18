class Product < ActiveRecord::Base
  belongs_to :inclusion, class_name: "Recipe"
  belongs_to :motherdough, class_name: "Recipe"
  has_many :product_prices
  accepts_nested_attributes_for :product_prices, allow_destroy: true

  PRODUCT_TYPE_OPTIONS = [:bread, :vienoisserie, :cookie, :tart, :quiche, :sandwich, :pot_pie, :dry_goods, :other]
  UNIT_OPTIONS = [:oz, :lb, :g, :kg]

  enum product_type: PRODUCT_TYPE_OPTIONS
  enum unit: UNIT_OPTIONS

  validates :name, presence: true, uniqueness: true
  validates :product_type, presence: true
  validates :description, length: { maximum: 500 }
  validates :weight, format: { with: /\A\d+(?:\.\d{0,3})?\z/ }, numericality: true
  validates :extra_amount, format: { with: /\A\d+(?:\.\d{0,3})?\z/ }, numericality: true

  def self.unit_options
    UNIT_OPTIONS
  end

  def self.product_type_options
    PRODUCT_TYPE_OPTIONS
  end
end
