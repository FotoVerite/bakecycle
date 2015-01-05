class PriceVarient < ActiveRecord::Base
  belongs_to :product

  validates :price, presence: true, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: true
  validates :quantity, presence: true, numericality: true
  validates :effective_date, presence: true, uniqueness:
            {
              scope: [:quantity, :product],
              message: "and quantity already exist for this product, try a different date"
            }
end
