require 'prawn/table'

class InvoicePdf < Prawn::Document
  def initialize(shipment)
    super(pdf_margins)
    @shipment = shipment
    @bakery = shipment.bakery
    setup_grid
    header
  end

  def pdf_margins
    {
      # set counter clockwise just like CSS
      margin: [50, 20, 75, 20]
    }
  end

  def setup_grid
    define_grid(columns: 12, rows: 10, gutter: 10)
    # Helper to show grid layout outline for your columns and rows
    # grid.show_all
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

  def bakery_logo
    return image @bakery.logo.path, fit: [280, 60] if @bakery.logo
    text_box @bakery.name.upcase, size: 80, overflow: :shrink_to_fit
  end

  def bakery_info
    font_size 7
    text @bakery.name
    text @bakery.address_street_1
    text @bakery.address_street_2
    text "#{@bakery.address_city}, #{@bakery.address_city} #{@bakery.address_zipcode}"
    text @bakery.phone_number
    text @bakery.email
  end
end
