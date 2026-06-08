# frozen_string_literal: true

class DetailedInvoiceReportXlsx
  def initialize(bakery, start_date, end_date)
    @bakery = bakery
    @shipments = Shipment.where(bakery: bakery, date: start_date..end_date) || []
  end

  def generate
    p = Axlsx::Package.new
    wb = p.workbook
    styles = wb.styles
    @header = styles.add_style bg_color: "DD", sz: 16, b: true, alignment: { horizontal: :center }
    @client_style = styles.add_style bg_color: "0000FF", fg_color: "FF", sz: 24, alignment: { horizontal: :center }
    wb.add_worksheet(name: "Invoices") do |sheet|
      sheet.add_row [
        "Invoice Number",
        "Client Name",
        "Client Group",
        "Client Channel",
        "Client ID",
        "Invoice Date",
        "Route",
        "Subtotal",
        "Fees",
        "Bread",
        "Cookie",
        "Pot Pie",
        "Quiche",
        "Sandwich & Tartine",
        "Tart and Desert",
        "Vienoisserie",
        "Dry Goods",
        "Other",
        "Total"
      ]
      add_rows(@shipments, sheet)
    end
    create_output_string(p)
  end

  def add_rows(shipments, sheet)
    shipments.each do |shipment|
      row = [
        shipment.invoice_number,
        shipment.client_name,
        shipment.client.group,
        shipment.client.channel,
        shipment.client_id,
        shipment.date,
        shipment.route_name,
        shipment.subtotal,
        shipment.delivery_fee
      ]
      row += create_totals_for_invoice(shipment).values
      sheet.add_row row
    end
  end

  def create_totals_for_invoice(shipment)
    hash = {
      bread: 0.00,
      cookie: 0.00,
      pot_pie: 0.00,
      quiche: 0.00,
      sandwich_and_tartine: 0.00,
      tart_and_desert: 0.00,
      vienoisserie: 0.00,
      dry_goods: 0.00,
      other: 0.00,
      total: 0.00
    }
    shipment.shipment_items.each do |item|
      product_type = item.product.product_type
      hash[product_type.to_sym] += (item.product_quantity * item.product_price)
      hash[:total] += (item.product_quantity * item.product_price)
    end
    hash
  end

  def create_output_string(page)
    outstrio = StringIO.new
    page.use_shared_strings = true # Otherwise strings don't display in iWork Numbers
    outstrio.write(page.to_stream.read)
    outstrio.string
  end
end
