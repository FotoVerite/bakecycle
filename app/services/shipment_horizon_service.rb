# frozen_string_literal: true

class ShipmentHorizonService
  HORIZON_DAYS = 10
  PotentialShipment = Struct.new(:order, :date, keyword_init: true)

  attr_reader :bakery, :run_time

  def initialize(bakery, run_time)
    @bakery = bakery
    @run_time = run_time
  end

  def run
    delivery_dates.flat_map do |delivery_date|
      active_orders_for(delivery_date).filter_map do |order|
        next unless order_has_quantity_for?(order, delivery_date)

        PotentialShipment.new(order: order, date: delivery_date)
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

  def order_has_quantity_for?(order, delivery_date)
    order.order_items.any? { |item| item.quantity(delivery_date).positive? }
  end
end
