# frozen_string_literal: true

class InvoicePage
  extend Forwardable
  include ActionView::Helpers::NumberHelper

  def_delegators :@pdf,
                 :start_new_page, :stamp_or_create, :bounding_box, :grid, :cursor,
                 :text, :font_size, :table, :move_down,
                 :bakery_logo_display, :bakery_info

  def initialize(shipment, bakery, pdf)
    @shipment = shipment.decorate
    @bakery = bakery
    @pdf = pdf
  end

  def render
    start_new_page
    invoice_header_stamp
    addresses
    note
    information
    shipment_items
    totals
  end

  private

  def invoice_header_stamp
    stamp_or_create("invoice header") { invoice_header }
  end

  def invoice_header
    bounding_box([0, cursor], width: 260, height: 60) { bakery_logo_display(@bakery) }
    grid([0, 5.5], [0, 8]).bounding_box { bakery_info(@bakery) }
    grid([0, 9], [0, 11]).bounding_box { text "Invoice", size: 40 }
  end

  def addresses
    grid([1.1, 0], [1.3, 4]).bounding_box do
      text "Shipped To:", size: 9
      client_address(:delivery)
    end
    grid([1.1, 5], [1.3, 9]).bounding_box do
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

  def information
    sizing = if @shipment.po_number.blank?
               [114.4, 114.4, 114.4, 114.4,
                114.4]
             else
               [95.33, 95.33, 95.33, 95.33, 95.33, 95.33]
             end
    table(information_rows, column_widths: sizing) do
      column(0..4).style(align: :center)
      row(0).style(background_color: @pdf.class::HEADER_ROW_COLOR)
      row(1).style(overflow: :shrink_to_fit, min_font_size: 10)
    end
  end

  def information_rows
    if @shipment.po_number.blank?
      [["Invoice Number", "Invoice Date", "Terms", "Due Date", "Total Due"]] +
        [[
          @shipment.invoice_number, @shipment.date, @shipment.terms,
          @shipment.payment_due_date, @shipment.price
        ]]
    else
      [["PO Number", "Invoice Number", "Invoice Date", "Terms", "Due Date", "Total Due"]] +
        [[
          @shipment.po_number,
          @shipment.invoice_number, @shipment.date, @shipment.terms,
          @shipment.payment_due_date, @shipment.price
        ]]
    end
  end

  def shipment_items
    move_down 20
    table(shipment_items_row, column_widths: [250, 80.5, 80.5, 80.5, 80.5]) do
      row(0).style(background_color: @pdf.class::HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1..4).style(align: :center)
    end
  end

  def shipment_items_row
    header = ["Item Name", "Product Type", "Quantity", "Price Each", "Total"]
    sorted_order_items = @shipment.shipment_items.sort_by { |item| [item.product_product_type, item.product_name] }
    items = merge_sorted_order_items_with_same_name_and_price(sorted_order_items)
    [header] + items
  end

  def merge_sorted_order_items_with_same_name_and_price(items)
    hash = {}
    items.each do |item|
      if hash[item.product_name].nil?
        hash[item.product_name] = [
          item.product_name,
          item.product_type,
          item.product_quantity,
          item.product_price,
          item.object.price
        ]
      elsif hash[item.product_name][3] == item.product_price
        hash[item.product_name][2] = hash[item.product_name][2] + item.product_quantity
        hash[item.product_name][4] = hash[item.product_name][4] + item.object.price
      else
        hash[item.product_name + item.id.to_s] = [
          item.product_name,
          item.product_type,
          item.product_quantity,
          item.product_price,
          item.price
        ]
      end
    end
    hash.values.map do |array|
      [
        array[0],
        array[1],
        array[2],
        sample_order? ? number_to_currency(0) : array[3],
        number_to_currency(sample_order? ? 0 : array[4])
      ]
    end
  end

  # Sample-order shipments are always free -- the invoice's grand total is
  # already zeroed (see Shipment#price / ShipmentCreator), so the per-line
  # "Price Each"/"Total" columns must be zeroed too. Otherwise a shipment
  # whose items still carry their original (pre-zeroing) product_price would
  # show real per-line prices next to a $0.00 total, which reads as a bug
  # rather than the deliberate "sample orders are free" behavior.
  def sample_order?
    @shipment.sample?
  end

  def totals
    move_down 5
    table(totals_row, position: :right, column_widths: [80.5, 80.5]) do
      cells.borders = []
      column(0).style(align: :right)
      column(1).borders = %i[top right bottom left]
      column(1).style(align: :center)
    end
  end

  def totals_row
    rows = [["Subtotal:", @shipment.subtotal], ["Delivery Fee:", @shipment.delivery_fee]]
    rows << ["Discount:", "-#{@shipment.discount_amount}"] if @shipment.discount?
    rows << ["Total:", @shipment.price]
    rows
  end

  def note
    notes_data if note_text.present?
  end

  def notes_data
    text "Notes", style: :bold
    text note_text
    move_down 15
  end

  # Sample orders bill at $0 by design (ShipmentCreator#shipment_items), so the
  # invoice needs to say why rather than looking like a pricing bug. Appended
  # after whatever staff already wrote in Special Notes, never replacing it --
  # and it's the whole Notes section when there's no note of their own.
  def note_text
    [@shipment.note.presence, ("SAMPLE ORDER" if @shipment.sample?)].compact.join("\n")
  end
end
