class ProductionRun < ActiveRecord::Base
  belongs_to :bakery
  has_many :shipment_items
  has_many :run_items, dependent: :destroy

  accepts_nested_attributes_for(
    :run_items,
    allow_destroy: true,
    reject_if: proc { |attributes| attributes['product_id'].blank? }
  )

  def self.for_date(date)
    where('date >= ? AND date < ?', date.beginning_of_day, date.end_of_day)
  end
end
