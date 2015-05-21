class ProductionRunPdf < PdfReport
  def initialize(run_data)
    @run_data = run_data
    @bakery = run_data.bakery.decorate
    super()
  end

  def setup
    header_stamp
    production_run_info
    products
    body
    timestamp
    run_stamp
  end

  def header_stamp
    stamp_or_create('header') { header }
  end

  def run_stamp
    repeat :all do
      bounding_box([0, bounds.bottom + 10], width: (bounds.width / 2.0)) do
        text run_label, size: 10, style: :bold, margin: 10
      end
    end
  end

  def run_label
    return "Production Run ##{@run_data.id}" if @run_data.id
    'Production Run PROJECTION'
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
    font_size 10
    text run_label
    text "#{@run_data.start_date} - #{@run_data.end_date}"
  end

  def body
    @run_data.recipes.each do |motherdough|
      RecipeDataPdf.new(self, motherdough).render_recipe
    end
  end

  def products
    move_down 15
    table(product_information_row, column_widths: [300, 120, 120, 30]) do
      row(0).style(background_color: HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1..2).style(align: :center)
    end
  end

  def product_information_row
    header = ['Product', 'Type', 'Qty', nil]
    rows = @run_data.products.map do |product|
      [product[:name],
       product[:type],
       product[:quantity],
       nil
      ]
    end
    rows.unshift(header)
  end
end
