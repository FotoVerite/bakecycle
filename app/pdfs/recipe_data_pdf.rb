class RecipeDataPdf
  attr_reader :recipe_data

  def initialize(pdf, recipe_data)
    @pdf = pdf
    @recipe_data = recipe_data
  end

  def method_missing(method, *args, &block)
    @pdf.send(method, *args, &block)
  end

  def render_recipe
    start_new_page
    page_layout
  end

  def page_layout
    define_grid(columns: 12, rows: 12, gutter: 10)
    grid([0, 0], [0, 8]).bounding_box do
      header
    end
    grid([1, 6], [6, 11]).bounding_box do
      right_section
    end
  end

  def right_section
    recipe_data_products
    inclusions if recipe_data.inclusions.any?
  end

  def header
    text "#{recipe_data.recipe.name}", size: 20
    text "#{recipe_data.recipe.recipe_type}", size: 20
  end

  def recipe_data_products
    table(recipe_data_products_row, column_widths: [140.5, 140.5]) do
      row(0).style(background_color: PdfReport::HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1).style(align: :center)
    end
  end

  def recipe_data_products_row
    header = ['Product Name', 'Qty']
    rows = recipe_data.products.map do |product|
      [product[:product].name,
       product[:quantity]
      ]
    end
    rows.unshift(header)
  end

  def inclusions
    move_down 40
    table(inclusions_row, column_widths: [281]) do
      row(0).style(background_color: PdfReport::HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1).style(align: :center)
    end
  end

  def inclusions_row
    header = %w(Inclusion)
    rows = recipe_data.inclusions.map do |inclusion|
      [inclusion.name]
    end
    rows.unshift(header)
  end
end
