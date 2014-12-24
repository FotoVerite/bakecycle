class Order < ActiveRecord::Base
  belongs_to :client
  belongs_to :route
  has_many :order_items
  accepts_nested_attributes_for :order_items, allow_destroy: true

  validates :route, :client, :start_date, presence: true
  validates :order_items, presence: true
end
