# frozen_string_literal: true

class DeliveryListXlsx
  def initialize(bakery, date)
    @bakery = bakery
    @date = date
    @shipments = Shipment.where(bakery: bakery, date: date).order("client_name ASC") || []
  end

  def generate
    p = Axlsx::Package.new
    wb = p.workbook
    styles = wb.styles
    @header = styles.add_style bg_color: "DD", sz: 16, b: true, alignment: { horizontal: :center }
    @client_style = styles.add_style bg_color: "0000FF", fg_color: "FF", sz: 24, alignment: { horizontal: :center }
    wb.add_worksheet(name: "Deliveries for #{@date}") do |sheet|
      add_rows(@shipments, sheet)
    end
    create_output_string(p)
  end

  def add_rows(shipments, sheet)
    # Set Product Type Row
    shipments.each do |s|
      sheet.add_row [s.client_name, s.route_name]
    end
  end

  def create_output_string(page)
    outstrio = StringIO.new
    page.use_shared_strings = true # Otherwise strings don't display in iWork Numbers
    outstrio.write(page.to_stream.read)
    outstrio.string
  end
end
