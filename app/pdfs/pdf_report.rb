class PdfReport < Prawn::Document
  HEADER_ROW_COLOR = 'b9b9b9'

  def initialize
    super(default_margin)
    font_size 10
    setup_grid
    setup
  end

  def setup
  end

  def setup_grid
    define_grid(columns: 12, rows: 12, gutter: 8)
  end

  def default_margin
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
    number_pages "Page <page> of <total>", options
  end
end
