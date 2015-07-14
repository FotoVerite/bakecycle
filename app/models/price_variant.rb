class PriceVariant < ActiveRecord::Base
  belongs_to :product
  belongs_to :client

  validates :price, presence: true
  validates :price, numericality: true, unless: 'price.blank?'
  validates :quantity, presence: true, uniqueness: {
    scope: [:product_id, :client_id],
    message: 'quantity already exists'
  }
  validates :quantity, numericality: true, unless: 'quantity.blank?'

  def client_name
    if client
      client.name
    else
      ''
    end
  end
end
