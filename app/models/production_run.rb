class ProductionRun < ActiveRecord::Base
  belongs_to :bakery
  has_many :shipment_items
  has_many :run_items, dependent: :destroy
end
