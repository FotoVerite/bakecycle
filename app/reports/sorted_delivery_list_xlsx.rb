# frozen_string_literal: true

class SortedDeliveryListXlsx
  include XlsxReport

  def initialize(bakery, date)
    @bakery = bakery
    @date = date
    @grouped_shipments = Shipment
      .where(bakery_id: 1, date: Time.zone.now - 1.year)
      .order("route_name ASC, client_name ASC")
      .group_by(&:route_name) || []
  end

  def generate
    p = Axlsx::Package.new
    wb = p.workbook
    styles = wb.styles
    @header = styles.add_style bg_color: "DD", sz: 16, b: true, alignment: { horizontal: :center }
    @client_style = styles.add_style bg_color: "0000FF", fg_color: "FF", sz: 24, alignment: { horizontal: :center }
    @grouped_shipments.each do |shipments_array|
      wb.add_worksheet(name: shipments_array[0].to_s) do |sheet|
        add_rows(shipments_array[1], sheet)
      end
    end
    create_output_string(p)
  end

  def add_rows(shipments, sheet)
    # Set Product Type Row
    shipments.each do |s|
      sheet.add_row [s.client_name, s.route_name]
    end
  end
end
