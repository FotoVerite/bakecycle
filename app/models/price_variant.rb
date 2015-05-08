class PriceVariant < ActiveRecord::Base
  belongs_to :product

  validates :price, presence: true, numericality: true
  validates :quantity, presence: true, numericality: true, uniqueness: {
      scope: :id,
      message: 'quantity already exist for this product'
    }
end
