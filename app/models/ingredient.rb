class Ingredient < ActiveRecord::Base
  UNIT_OPTIONS = [:oz, :lb, :g, :kg]
  enum unit: UNIT_OPTIONS

  validates :name, presence: true, uniqueness: true, length: { maximum: 150 }
  validates :price, format: { with: /\A\d+(?:\.\d{0,2})?\z/}, numericality: true, length: {maximum: 9}
  validates :measure, format: { with: /\A\d+(?:\.\d{0,3})?\z/ }, numericality: true, length: { maximum: 9 }
  validates :description, length: { maximum: 500 }

  def self.unit_options
    UNIT_OPTIONS
  end
end
