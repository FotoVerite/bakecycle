# frozen_string_literal: true

class ProductDeliveryProjectionGenerator
  include Generator

  def self.find(global_id)
    bakery_id, date_string = global_id.split("_")
    bakery = Bakery.find(bakery_id)
    new(bakery, Date.iso8601(date_string))
  end

  def initialize(bakery, date)
    @bakery = bakery
    @date = date.to_date
  end

  def id
    "#{@bakery.id}_#{@date.iso8601}_delivery_product_projection"
  end

  def filename
    "DeliveryProductProjection-#{@date.iso8601}.xlsx"
  end

  def generate
    DeliveryProductProjectionXlsx.new(@bakery, @date).generate
  end
end
