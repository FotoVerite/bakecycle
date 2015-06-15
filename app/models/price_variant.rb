class PriceVariant < ActiveRecord::Base
  belongs_to :product

  validates :price, presence: true
  validates :price, numericality: true, unless: 'price.blank?'
  validates :quantity, presence: true, uniqueness: {
      scope: :id,
      message: 'quantity already exist for this product'
    }
  validates :quantity, numericality: true, unless: 'quantity.blank?'
end
