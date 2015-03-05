class PriceVarient < ActiveRecord::Base
  belongs_to :product

  validates :price, presence: true, numericality: true, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }
  validates :quantity, presence: true, numericality: true, uniqueness: {
      scope: :id,
      message: 'quantity already exist for this product'
    }
end
