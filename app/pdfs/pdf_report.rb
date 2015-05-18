class PdfReport < Prawn::Document
  HEADER_ROW_COLOR = 'b9b9b9'
  INDENTED_ROW_COLOR = 'd3d3d3'

  def initialize(options = {})
    super(default_options.merge(options))
    font_size 10
    setup_grid
    @stamps = {}
    setup
  end

  def setup
  end

  def stamp_or_create(name, &block)
    return stamp(name) if @stamps[name]
    create_stamp(name, &block)
    @stamps[name] = true
    stamp(name)
  end

  def setup_grid
    define_grid(columns: 12, rows: 12, gutter: 8)
  end

  def default_options
    { margin: [20, 20, 20, 20] }
  end

  def number_of_pages
    options = {
      at: [bounds.left, bounds.bottom + 10],
      width: bounds.width / 2.0,
      align: :left,
      start_count_at: 1,
      size: 8
    }
    number_pages 'Page <page> of <total>', options
  end

  def printed_today
    "Printed at #{current_date} at#{current_time}"
  end

  def current_date
    Time.zone.today.strftime('%A %B %e, %Y')
  end

  def current_time
    Time.zone.now.strftime('%l:%M%P')
  end

  def timestamp
    repeat :all do
      bounding_box([288, bounds.bottom + 10], width: (bounds.width / 2.0)) do
        text printed_today, size: 8, align: :right
      end
    end
  end

  def bakery_logo_display(bakery)
    bakery_logo_image = bakery.logo_local_file(:invoice)
    return image bakery_logo_image, fit: [260, 60] if bakery_logo_image
    text_box bakery.name.upcase, size: 60, overflow: :shrink_to_fit
  end

  def bakery_info(bakery)
    font_size 7
    text bakery.name
    text bakery.address_street_1
    text bakery.address_street_2 if bakery.address_street_2.present?
    text bakery.city_state_zip
    text bakery.phone_number
    text bakery.email
  end

  def footer
    number_of_pages
    timestamp
  end
end
