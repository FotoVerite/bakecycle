# frozen_string_literal: true

class ClientDecorator < Draper::Decorator
  delegate_all

  decorates_association :orders

  def active_status
    active ? "Yes" : "No"
  end

  def billing
    billing_term&.humanize(capitalize: false)&.titleize
  end

  def delivery_fee_display
    delivery_fee_option&.humanize(capitalize: false)&.titleize
  end

  def latest_orders
    object.orders.includes(:route).order_by_active.limit(10).decorate
  end

  def active_days
    out = {}
    standing_orders.active_orders.map(&:order_items).flatten.each do |i|
      OrderItem::DAYS_OF_WEEK.each do |d|
        out[d] = true if i.send(d).positive?
      end
    end
    return "Every Day" if out.keys.size == 7

    out.keys.map(&:capitalize).join(", ")
  end

  def latest_shipments
    object.shipments.includes(:shipment_items).latest(10).decorate
  end
end
