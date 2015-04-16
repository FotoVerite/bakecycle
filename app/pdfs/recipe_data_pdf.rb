class RecipeDataPdf
  attr_reader :recipe_run_data, :display_precision

  def initialize(pdf, recipe_run_data)
    @pdf = pdf
    @recipe_run_data = recipe_run_data
    @display_precision = 3
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
    grid([0, 0], [1, 8]).bounding_box do
      header
    end
    grid([1, 0], [11, 11]).bounding_box do
      right_section
    end
  end

  def right_section
    recipe_run_data_products
    inclusions if recipe_run_data.inclusions.any?
  end

  def header
    text "#{recipe_run_data.recipe.name}", size: 20
    text "#{recipe_run_data.recipe.recipe_type}", size: 20
    text "#{recipe_run_data.weight.round(display_precision)}", size: 10
  end

  def recipe_run_data_products
    table(recipe_run_data_products_row, column_widths: [140.5, 70.25, 70.25, 70.25]) do
      row(0).style(background_color: PdfReport::HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1).style(align: :center)
    end
  end

  def recipe_run_data_products_row
    header = ['Product Name', 'Qty', 'Per Item Weight', 'Total Weight']
    rows = recipe_run_data.products.map do |product|
      [
        product[:product].name,
        product[:quantity],
        product[:product].weight_with_unit.round(display_precision).to_s,
        product[:weight].to_s
      ]
    end
    rows.unshift(header)
  end

  def inclusions
    move_down 40
    table(inclusions_rows, column_widths: [281]) do
      row(0).style(background_color: PdfReport::HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1).style(align: :center)
    end
  end

  def inclusions_rows
    header = %w(Inclusion Weight)
    rows = recipe_run_data.inclusions.map do |data|
      [data[:recipe].name, data[:weight].round(display_precision).to_s]
    end
    rows.unshift(header)
  end
end
