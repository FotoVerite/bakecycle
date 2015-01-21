class Order < ActiveRecord::Base
  belongs_to :client
  belongs_to :route
  has_many :order_items
  accepts_nested_attributes_for :order_items, allow_destroy: true

  validates :route, :route_id, presence: true
  validates :client, :client_id, presence: true
  validates :start_date, presence: true
  validates :order_items, presence: { message: "You must choose a product before saving" }
  validates :order_type, presence: true

  before_validation :set_end_date, if: :temporary?

  def set_end_date
    self.end_date = start_date
  end

  def temporary?
    order_type == "temporary"
  end
end
