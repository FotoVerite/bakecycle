class ProductPrice < ActiveRecord::Base
  belongs_to :product

  validates :price, presence: true, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: true
  validates :quantity, presence: true, numericality: true
  validates :effective_date, presence: true
end
