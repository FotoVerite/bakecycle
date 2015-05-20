class PackingSlipPdf
  def initialize(shipment, bakery, pdf)
    @shipment = shipment.decorate
    @bakery = bakery
    @pdf = pdf
    @shipment_items = shipment.shipment_items.sort_by { |item| [item.product_product_type, item.product_name] }
  end

  def method_missing(method, *args, &block)
    @pdf.send(method, *args, &block)
  end

  def setup
    packing_slip_header_stamp
    addresses
    packing_slip_info
    note if @shipment.note
    shipment_items_table
    pieces_shipped
  end

  def packing_slip_header_stamp
    stamp_or_create('packing slip header') { packing_slip_header }
  end

  def packing_slip_header
    bounding_box([0, cursor], width: 260, height: 60) do
      bakery_logo_display(@bakery)
    end
    grid([0, 5.5], [0, 8]).bounding_box do
      bakery_info(@bakery)
    end
    grid([0, 9], [0, 11]).bounding_box do
      text 'Packing Slip', size: 20
    end
  end

  def addresses
    grid([1.5, 0], [1.7, 3]).bounding_box do
      text 'Shipped To:', size: 9
      client_address(:delivery)
    end
    grid([1.5, 4], [1.7, 7]).bounding_box do
      text 'Billed To:', size: 9
      client_address(:billing)
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

  def note
    text "Note: #{@shipment.note}"
    move_down 15
  end

  def shipment_items_table
    table(shipment_items_rows, column_widths: [300, 100, 57.3, 57.3, 57.3])do
      row(0).style(background_color: @pdf.class::HEADER_ROW_COLOR)
      column(0).style(align: :left)
      row(1..-1).column(2..3).style(font_style: :bold)
      column(1..-1).style(align: :center)
    end
  end

  def packing_slip_info
    grid([1.5, 8], [1.7, 8]).bounding_box do
      font_size 9
      packing_slip_info_data.each do |row|
        text row[0], align: :right
      end
    end
    grid([1.5, 9], [1.7, 11]).bounding_box do
      font_size 9
      packing_slip_info_data.each do |row|
        text "#{row[1]}", align: :left
      end
    end
  end

  def packing_slip_info_data
    [
      ['Date:', @shipment.date],
      ['Invoice #:', @shipment.invoice_number],
      ['Route:', @shipment.route_name],
    ]
  end

  def shipment_items_rows
    header = ['Item Name', 'Product Type', 'Ordered', 'Shipped', 'Pack Check']
    rows = @shipment_items.map do |item|
      item = item.decorate
      [item.product_name_and_sku, item.product_product_type, item.product_quantity, item.product_quantity, nil]
    end
    rows.unshift(header)
  end

  def pieces_shipped
    table(pieces_shipped_row, position: :right, column_widths: [400, 57.3, 57.3, 57.3]) do
      cells.borders = []
      column(0).style(align: :right, font_style: :bold)
      column(1).borders = [:top, :right, :bottom, :left]
      column(1).style(align: :center, font_style: :bold)
    end
  end

  def pieces_shipped_row
    [
      ['Total pieces shipped:', @shipment.total_quantity, nil],
      ['# BOXES shipped:', nil, nil],
      ['# BAGS shipped:', nil, nil]
    ]
  end
end
