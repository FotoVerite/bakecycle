# frozen_string_literal: true

class DeliveryProductProjectionXlsx
  HEADERS = ["Product", "Individual Count", "Tray Count"].freeze

  def initialize(bakery, date)
    @bakery = bakery
    @date = date.to_date
  end

  def generate
    package = Axlsx::Package.new
    workbook = package.workbook
    styles = workbook.styles
    header_style = styles.add_style(bg_color: "EAF6FC", fg_color: "0B5B84", b: true)

    workbook.add_worksheet(name: "Product Projection") do |sheet|
      sheet.add_row ["Delivery Product Projection", @date.iso8601]
      sheet.add_row []
      sheet.add_row HEADERS, style: header_style
      product_rows.each { |row| sheet.add_row row }
    end

    create_output_string(package)
  end

  def product_rows
    totals_by_product.map do |product, quantity|
      [product.name, quantity, tray_count_for(product, quantity)]
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

  def totals_by_product
    ShipmentItem
      .joins(:shipment, :product)
      .where(shipments: { bakery_id: @bakery.id, date: @date })
      .includes(:product)
      .group_by(&:product)
      .sort_by { |product, _items| product.name }
      .to_h do |product, items|
        [product, items.sum(&:product_quantity)]
      end
  end

  def create_output_string(page)
    outstrio = StringIO.new
    page.use_shared_strings = true
    outstrio.write(page.to_stream.read)
    outstrio.string
  end
end
