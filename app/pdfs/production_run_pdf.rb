class ProductionRunPdf < PdfReport
  def initialize(production_run_data)
    @production_run = production_run_data
    @bakery = production_run_data.bakery.decorate
    super()
  end

  def setup
    header_stamp
    production_run_info
    products
    body
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
  end

  def production_run_info
    font_size 12
    text "Production Run ##{@production_run.id}"
    text "#{@production_run.start_date} - #{@production_run.end_date}"
  end

  def body
    bounding_box([bounds.left, bounds.top - 80], width:  bounds.width, height: bounds.height - 50) do
      start_new_page
      recipes
    end
  end

  def recipes
    @production_run.motherdoughs.each do |motherdough|
      text motherdough.name, size: 20
      start_new_page unless motherdough == @production_run.motherdoughs.last
    end
  end

  def products
    move_down 40
    table(product_information_row, column_widths: [380, 190]) do
      row(0).style(background_color: HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1).style(align: :center)
    end
  end

  def product_information_row
    header = %w(Product Qty)
    rows = @production_run.products.map do |product|
      [product[:name],
       product[:quantity]
      ]
    end
    rows.unshift(header)
  end
end
