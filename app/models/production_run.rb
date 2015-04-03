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
    all.collect { |run| run if run.date.beginning_of_day == date.beginning_of_day }.compact
  end
end
