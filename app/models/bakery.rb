class Bakery < ActiveRecord::Base
  has_many :ingredients
  has_many :clients
  has_many :recipes
  has_many :orders
  has_many :products
  has_many :routes
  has_many :shipments
  has_many :users

  validates :name, presence: true, uniqueness: true, length: { maximum: 150 }
  has_attached_file :logo, styles: { invoice: "1800x200>", thumb: "300x200>" }
  validates_attachment :logo, content_type: { content_type: /^image\/(jpeg|png|tiff|bmp)$/ }
end
