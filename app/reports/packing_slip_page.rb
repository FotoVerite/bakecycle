class PackingSlipPage
  def initialize(shipment, bakery, pdf)
    @shipment = shipment.decorate
    @bakery = bakery
    @pdf = pdf
    @shipment_items = shipment.shipment_items.sort_by { |item| [item.product_product_type, item.product_name] }
  end

  def render
    start_new_page
    packing_slip_header_stamp
    addresses
    packing_slip_info
    notes
    shipment_items_table
    pieces_shipped
  end

  private

  def method_missing(method, *args, &block)
    @pdf.send(method, *args, &block)
  end

  def packing_slip_header_stamp
    stamp_or_create("packing slip header") { packing_slip_header }
  end

  def packing_slip_header
    bounding_box([0, cursor], width: 260, height: 60) { bakery_logo_display(@bakery) }
    grid([0, 5.5], [0, 8]).bounding_box { bakery_info(@bakery) }
    grid([0, 9], [0, 11]).bounding_box { text "Packing Slip", size: 20 }
  end

  def addresses
    grid([1.1, 0], [1.3, 3]).bounding_box do
      text "Shipped To:", size: 9
      client_address(:delivery)
    end
    grid([1.1, 4], [1.3, 7]).bounding_box do
      text "Billed To:", size: 9
      client_address(:billing)
    end
  end

  # This calls
  # shipment.client_delivery_address
  # shipment.client_billing_address
  def client_address(type)
    font_size 10
    text @shipment.client_name, style: :bold
    full_array = @shipment.send(:"client_#{type}_address").full_array
    full_array.each do |line|
      text line, style: :bold
    end
  end

  def shipment_items_table
    return if shipment_items_rows.length == 1
    table(shipment_items_rows, column_widths: [300, 100, 57.3, 57.3, 57.3]) do
      row(0).style(background_color: @pdf.class::HEADER_ROW_COLOR)
      column(0).style(align: :left)
      row(1..-1).column(2..3).style(font_style: :bold)
      column(1..-1).style(align: :center)
    end
  end

  def packing_slip_info
    grid([1.1, 8], [1.3, 8]).bounding_box do
      font_size 9
      packing_slip_info_data.each do |row|
        text row[0], align: :right
      end
    end
    grid([1.1, 9], [1.3, 11]).bounding_box do
      font_size 9
      packing_slip_info_data.each do |row|
        text (row[1]).to_s, align: :left
      end
    end
  end

  def packing_slip_info_data
    [
      ["Date:", @shipment.date],
      ["Invoice #:", @shipment.invoice_number],
      ["Route:", @shipment.route_name]
    ]
  end

  def shipment_items_rows
    header = ["Item Name", "Product Type", "Ordered", "Shipped", "Pack Check"]
    rows = @shipment_items.map do |item|
      item = item.decorate
      [item.product_name_and_sku, item.product_type, item.product_quantity, item.product_quantity, nil]
    end
    rows.unshift(header)
  end

  def pieces_shipped
    table(pieces_shipped_row, position: :right, column_widths: [400, 57.3, 57.3, 57.3]) do
      cells.borders = []
      column(0).style(align: :right, font_style: :bold)
      column(1).borders = %i[top right bottom left]
      column(1).style(align: :center, font_style: :bold)
    end
  end

  def pieces_shipped_row
    [
      ["Total pieces shipped:", @shipment.total_quantity, nil],
      ["# BOXES shipped:", nil, nil],
      ["# BAGS shipped:", nil, nil]
    ]
  end

  def shipment_or_client_notes_present?
    @shipment.client_notes.present? || @shipment.note.present?
  end

  def notes
    notes_data if shipment_or_client_notes_present?
  end

  def notes_data
    text "Notes", style: :bold
    text @shipment.client_notes if @shipment.client_notes.present?
    text @shipment.note if @shipment.note.present?
    move_down 15
  end
end
