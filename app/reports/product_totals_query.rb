# frozen_string_literal: true

# Product totals for a bakery over a date range, from either the live order
# projection or already-created shipments. Single source of truth for the
# Product Totals report AND ProductTotalsSnapshot.capture! -- a snapshot must
# record exactly what the report would have said at that moment, so both must
# go through this class rather than reimplementing the aggregation.
class ProductTotalsQuery
  DEFAULT_SOURCE = "order_projection"
  SOURCES = [DEFAULT_SOURCE, "generated_invoices"].freeze

  def self.normalize_source(source)
    source = source.to_s.presence || DEFAULT_SOURCE
    SOURCES.include?(source) ? source : DEFAULT_SOURCE
  end

  def initialize(bakery, start_date, end_date, source: DEFAULT_SOURCE)
    @bakery = bakery
    @start_date = start_date.to_date
    @end_date = end_date.to_date
    @source = self.class.normalize_source(source)
  end

  # => [[delivery_date, product, quantity], ...] sorted by date then product name
  def totals
    order_projection? ? order_projection_totals : invoice_totals
  end

  private

  def order_projection_totals
    delivery_dates.each_with_object(Hash.new(0)) do |delivery_date, totals|
      active_orders_for(delivery_date).each do |order|
        order.order_items.each do |item|
          quantity = item.quantity(delivery_date)
          totals[[delivery_date, item.product]] += quantity if quantity.positive?
        end
      end
    end.sort_by { |(delivery_date, product), _quantity| [delivery_date, product.name] }
      .map { |(delivery_date, product), quantity| [delivery_date, product, quantity] }
  end

  # Aggregated in SQL on purpose: a 14-day range can hold >10k shipment_items,
  # and materializing them (each with its wide denormalized shipment row)
  # costs over a second of allocation + GC just to sum quantities.
  def invoice_totals
    sums = ShipmentItem
      .joins(:shipment)
      .where(shipments: { bakery_id: @bakery.id, date: delivery_dates })
      .group("shipments.date", :product_id)
      .sum(:product_quantity)
    products = Product.where(id: sums.keys.map(&:last).uniq).index_by(&:id)

    sums.filter_map do |(delivery_date, product_id), quantity|
      product = products[product_id]
      [delivery_date, product, quantity] if product
    end.sort_by { |delivery_date, product, _quantity| [delivery_date, product.name] }
  end

  def delivery_dates
    @start_date..@end_date
  end

  def active_orders_for(delivery_date)
    @bakery
      .orders
      .active(delivery_date)
      .includes(order_items: :product)
  end

  def order_projection?
    @source == DEFAULT_SOURCE
  end
end
