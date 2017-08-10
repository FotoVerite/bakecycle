class OrderPdf < BasePdfReport
  def initialize(order)
    @order = order.decorate
    @bakery = order.bakery.decorate
    super()
  end

  private

  def setup
    order_header
    note
    information
    grouped_tables
    footer
  end

  def order_header
    bounding_box([0, cursor], width: 260, height: 60) { bakery_logo_display(@bakery) }
    grid([0, 5.5], [0, 8]).bounding_box { bakery_info(@bakery) }
    grid([0, 8], [0, 11]).bounding_box do
      text(@order.client.name, size: 15, align: :right, style: :bold)
      text("#{@order.order_type.titleize} Order", size: 15, align: :right, style: :italic)
    end
  end

  def information
    table(information_rows, column_widths: [200, 93, 93, 93, 93]) do
      column(0..4).style(align: :center)
      row(0).style(background_color: HEADER_ROW_COLOR)
      row(1).style(overflow: :shrink_to_fit, min_font_size: 10)
    end
  end

  def information_rows
    [["Client", "Order Type", "Route", "Start Date", "End Date"]] +
      [[
        @order.client.name, @order.order_type.capitalize, @order.route_name, @order.start_date,
        @order.end_date
      ]]
  end

  def grouped_tables
    @order.order_items.object.group_and_order_by_product.each { |group| items_table(group) }
  end

  def items_table(group)
    move_down 20
    text group[0].capitalize.to_s, style: :bold, size: 15
    table(order_items_rows(group[1]), column_widths: [200, 70, 70, 33, 33, 33, 33, 33, 33, 33]) do
      row(0).style(background_color: HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1..9).style(align: :center)
    end
  end

  def order_items_rows(order_items)
    header = ["Product", "Unit Price", "Order Price", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    [header] + order_items.map { |item| item_row(item) }.compact
  end

  def item_row(item)
    return if item.total_quantity.zero?
    item = item.decorate
    [
      item.product.name,
      item.product_price_and_quantity,
      item.total_quantity_price_currency,
      item.monday,
      item.tuesday,
      item.wednesday,
      item.thursday,
      item.friday,
      item.saturday,
      item.sunday
    ]
  end

  def note
    notes_data if @order.note.present?
  end

  def notes_data
    text "Notes", style: :bold
    text @order.note
    move_down 15
  end
end
