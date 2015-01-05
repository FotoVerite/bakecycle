class Order < ActiveRecord::Base
  belongs_to :client
  belongs_to :route
  has_many :order_items
  accepts_nested_attributes_for :order_items, allow_destroy: true

  validates :route, :client, :start_date, presence: true
  validates :order_items, presence: true
  validates :order_type, presence: true

  before_validation :set_end_date, if: :temporary?

  def set_end_date
    self.end_date = start_date
  end

  def temporary?
    order_type == "temporary"
  end
end
