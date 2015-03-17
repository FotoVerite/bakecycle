class InvoicePdf < PdfReport
  def initialize(shipment, bakery)
    @shipment = shipment
    @bakery = bakery.decorate
    super()
  end

  def setup
    invoice
    footer
  end

  def invoice
    header_stamp
    addresses
    note
    information
    shipment_items
    totals
  end

  def header_stamp
    stamp_or_create('header') { header }
  end

  def header
    bounding_box([0, cursor], width: 260, height: 60) do
      bakery_logo_display(@bakery)
    end
    grid([0, 5.5], [0, 8]).bounding_box do
      bakery_info(@bakery)
    end
    grid([0, 9], [0, 11]).bounding_box do
      text 'Invoice', size: 40
    end
  end

  def addresses
    grid([1.5, 0], [1.9, 3]).bounding_box do
      text 'Shipped To:', size: 9
      client_address(:delivery)
    end
    grid([1.5, 4], [1.9, 7]).bounding_box do
      text 'Billed To:', size: 9
      client_address(:billing)
    end
  end

  def note
    grid([1.5, 8], [1.9, 11]).bounding_box do
      text 'Notes:', size: 9
      text @shipment.note, size: 10
    end
  end

  def client_address(type)
    font_size 10
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
      row(1).style(overflow: :shrink_to_fit, min_font_size: 10)
    end
  end

  def information_rows
    [['Invoice Number', 'Invoice Date', 'Terms', 'Due Date', 'Total Due']] +
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
    header = ['Item Name', 'Quantity', 'Price Each', 'Total']
    rows = @shipment.shipment_items.map do |item|
      [item.product_name, item.product_quantity, item.product_price, item.price]
    end
    rows.unshift(header)
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
    [['Subtotal:', @shipment.subtotal], ['Delivery Fee:', @shipment.delivery_fee], ['Total:', @shipment.price]]
  end
end
