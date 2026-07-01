# frozen_string_literal: true

class ProductTotalsDateRangeXlsx
  HORIZON_DAYS = 10
  HEADERS = ["Delivery Date", "Product", "Individual Count", "Tray Count"].freeze
  DEFAULT_SOURCE = "order_projection"
  SOURCES = [DEFAULT_SOURCE, "generated_invoices"].freeze

  def initialize(bakery, date, end_date: nil, source: DEFAULT_SOURCE)
    @bakery = bakery
    @date = date.to_date
    @end_date = (end_date || @date + HORIZON_DAYS.days).to_date
    @source = self.class.normalize_source(source)
  end

  def self.normalize_source(source)
    source = source.to_s.presence || DEFAULT_SOURCE
    SOURCES.include?(source) ? source : DEFAULT_SOURCE
  end

  def generate
    package = Axlsx::Package.new
    workbook = package.workbook
    styles = workbook.styles
    header_style = styles.add_style(bg_color: "EAF6FC", fg_color: "0B5B84", b: true)

    workbook.add_worksheet(name: "Product Totals") do |sheet|
      sheet.add_row ["Product Totals", "#{@date.iso8601} through #{@end_date.iso8601}"]
      sheet.add_row []
      sheet.add_row HEADERS, style: header_style
      product_rows.each { |row| sheet.add_row row }
    end

    create_output_string(package)
  end

  def product_rows
    totals.map do |delivery_date, product, quantity|
      [delivery_date.iso8601, product.name, quantity, tray_count_for(product, quantity)]
    end
  end

  def tray_count_for(product, quantity)
    return nil if product.pieces_per_tray.blank?

    tray_size = product.pieces_per_tray
    trays = quantity / tray_size
    pieces = quantity % tray_size
    parts = []
    parts << "#{trays} #{'tray'.pluralize(trays)}" if trays.positive?
    parts << "#{pieces} #{'piece'.pluralize(pieces)}" if pieces.positive?
    parts.join(", ")
  end

  private

  def totals
    order_projection? ? order_projection_totals : invoice_totals
  end

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

  def invoice_totals
    ShipmentItem
      .joins(:shipment, :product)
      .where(shipments: { bakery_id: @bakery.id, date: delivery_dates })
      .includes(:product, :shipment)
      .group_by { |item| [item.shipment.date, item.product] }
      .sort_by { |(delivery_date, product), _items| [delivery_date, product.name] }
      .map do |(delivery_date, product), items|
        [delivery_date, product, items.sum(&:product_quantity)]
      end
  end

  def delivery_dates
    @date..@end_date
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

  def create_output_string(page)
    outstrio = StringIO.new
    page.use_shared_strings = true
    outstrio.write(page.to_stream.read)
    outstrio.string
  end
end
