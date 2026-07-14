# frozen_string_literal: true

class ShipmentService
  attr_reader :bakery, :run_time

  def initialize(bakery, run_time)
    @bakery = bakery
    @run_time = run_time
  end

  def run
    order_items_for_production.each do |item|
      ship_date = run_time + item.total_lead_days.days
      ShipmentCreator.new(item.order, ship_date).create!
    end
  end

  private

  def order_items_for_production
    bakery.order_items.includes(:order).production_date(run_time)
  end
end
