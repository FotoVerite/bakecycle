class DeliveryListPdf < BasePdfReport
  def initialize(bakery, date)
    @recipes = ProductCounter.new(bakery, date)
    @bakery = bakery.decorate
    @date = date
    super()
  end

  def setup
    header
    body
    footer
  end

  def header
    repeat :all do
      bounding_box([0, cursor], width: 260, height: 60) do
        bakery_logo_display(@bakery)
      end
      grid([0, 5.5], [0, 8]).bounding_box do
        bakery_info(@bakery)
      end
      grid([0.2, 8], [0.2, 11]).bounding_box do
        text "Client Delivery List", size: 13, align: :right, style: :bold
      end
      grid([0.41, 8], [0.41, 11]).bounding_box do
        text delivery_date, size: 13, align: :right, style: :italic
      end
    end
  end

  def body
    bounding_box([bounds.left, bounds.top - 80], width: bounds.width, height: bounds.height - 100) do
      routes
    end
  end

  def routes
    @recipes.routes.each do |route|
      text route.name, size: 20
      @route = route
      clients
      start_new_page unless route == @recipes.routes.last
    end
  end

  def clients
    table(client_data, column_widths: [160, 100, 80, 180, 52]) do
      column(0..-1).style(size: 9)
      row(0).style(background_color: HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(2..4).style(align: :center)
    end
  end

  def client_data
    header = ["Client Name", "Contact", "Phone", "Address", "D-time"]
    client_rows.unshift(header)
  end

  def client_rows
    rows = []
    @recipes.route_shipment_clients(@route).each do |client|
      rows << [
        client.name,
        client.primary_contact_name,
        client.primary_contact_phone,
        client.delivery_address.full,
        nil
      ]
      rows << client_notes_row(client) if client.notes.present?
    end
    rows
  end

  def client_notes_row(client)
    [content: client.notes, colspan: 5, background_color: "FFFFCC"]
  end

  def delivery_date
    @date.strftime("%A %B %e, %Y")
  end
end
