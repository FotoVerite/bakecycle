# frozen_string_literal: true

class ShipmentHorizonService
  HORIZON_DAYS = 10

  attr_reader :bakery, :run_time

  def initialize(bakery, run_time)
    @bakery = bakery
    @run_time = run_time
  end

  def run
    delivery_dates.each do |delivery_date|
      active_orders_for(delivery_date).find_each do |order|
        ShipmentCreator.new(order, delivery_date).create!
      end
    end
  end

  private

  def delivery_dates
    start_date = run_time.to_date
    start_date..(start_date + HORIZON_DAYS.days)
  end

  def active_orders_for(delivery_date)
    bakery
      .orders
      .active(delivery_date)
      .includes(:client, :route, order_items: { product: :price_variants })
  end
end
