require 'prawn/table'

class InvoicePdf < Prawn::Document
  HEADER_ROW_COLOR = 'b9b9b9'

  def initialize(shipment)
    super(pdf_margins)
    @shipment = shipment
    setup_grid
    header
    addresses
    information
    shipment_items
    totals
  end

  def pdf_margins
    { margin: [50, 20, 75, 20] }
  end

  def setup_grid
    define_grid(columns: 12, rows: 12, gutter: 8)
  end

  def header
    bounding_box([0, cursor], width: 280, height: 60) do
      bakery_logo
    end

    grid([0, 6], [0, 8]).bounding_box do
      bakery_info
    end

    grid([0, 9], [0, 11]).bounding_box do
      text "Invoice", size: 40
    end
  end

  def addresses
    grid([2, 0], [3, 5]).bounding_box do
      text "Shipped To:", size: 14
      client_address(:delivery)
    end

    grid([2, 6], [3, 12]).bounding_box do
      text "Billed To:", size: 14
      client_address(:billing)
    end
  end

  def bakery_logo
    return image @shipment.bakery_logo_path, fit: [280, 60] if @shipment.bakery_logo
    text_box @shipment.bakery_name.upcase, size: 80, overflow: :shrink_to_fit
  end

  def bakery_info
    font_size 7
    text @shipment.bakery_name
    text @shipment.bakery_address_street_1
    text @shipment.bakery_address_street_2 if @shipment.bakery_address_street_2.present?
    text @shipment.bakery_city_state_zip
    text @shipment.bakery_phone_number
    text @shipment.bakery_email
  end

  def client_address(type)
    font_size 14
    text @shipment.send("client_#{type}_name"), style: :bold
    text @shipment.send("client_#{type}_address_street_1"), style: :bold
    if @shipment.send("client_#{type}_address_street_2")
      text @shipment.send("client_#{type}_address_street_2"), style: :bold
    end
    text @shipment.send("client_#{type}_city_state_zip"), style: :bold
  end

  def information
    table(information_rows, column_widths: [114.4, 114.4, 114.4, 114.4, 114.4])  do
      column(0..4).style(align: :center)
      row(0).style(background_color: HEADER_ROW_COLOR)
      row(1).style(overflow: :shrink_to_fit, min_font_size: 10, height: 35)
    end
  end

  def information_rows
    [["Invoice Number", "Invoice Date", "Terms", "Due Date", "Total Due"]] +
      [[
        @shipment.invoice_number, @shipment.date, @shipment.terms,
        @shipment.payment_due_date, @shipment.price
      ]]
  end

  def shipment_items
    move_down 20
    table(shipment_items_row, column_widths: [272, 100, 100, 100])do
      row(0).style(background_color: HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1..3).style(align: :center)
    end
  end

  def shipment_items_row
    [["Item Name", "Quantity", "Price Each", "Total"]] +
      @shipment.shipment_items.map do |item|
        [item.product_name, item.product_quantity, item.product_price, item.price]
      end
  end

  def totals
    move_down 5
    table(totals_row, position: :right, column_widths: [100, 100]) do
      cells.borders = []
      column(0).style(align: :right)
      column(1).borders = [:top, :right, :bottom, :left]
      column(1).style(align: :center)
    end
  end

  def totals_row
    [["Subtotal:", @shipment.subtotal], ["Delivery Fee:", @shipment.delivery_fee], ["Total:", @shipment.price]]
  end
end
