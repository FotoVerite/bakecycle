# == Schema Information
#
# Table name: price_variants
#
#  id         :integer          not null, primary key
#  product_id :integer          not null
#  price      :decimal(, )      default(0.0), not null
#  quantity   :integer          not null
#  created_at :datetime
#  updated_at :datetime
#  client_id  :integer
#  removed    :integer          default(0)
#

class PriceVariant < ApplicationRecord
  has_paper_trail

  belongs_to :product
  belongs_to :client

  validates :price, presence: true
  validates :price, numericality: true, unless: "price.blank?"
  validates :quantity, presence: true, uniqueness: {
    scope: %i[product_id client_id],
    message: "quantity already exists"
  }
  validates :quantity, numericality: true, unless: "quantity.blank?"

  def client_name
    if client
      client.name
    else
      ""
    end
  end

  def destroy
    self.removed = true
    save
  end
end
