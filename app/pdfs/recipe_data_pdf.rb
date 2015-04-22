# rubocop:disable Metrics/ClassLength
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
    grid([1, 0], [11, 5]).bounding_box do
      left_section
    end
    grid([1, 6], [11, 11]).bounding_box do
      right_section
    end
  end

  def right_section
    products_table if recipe_run_data.products.any?
    inclusions_table if recipe_run_data.inclusions.any?
    deeply_nested_recipes_table if recipe_run_data.parent_recipes.any?
  end

  def left_section
    ingredients_table
    nested_recipes_table if recipe_run_data.nested_recipes.any?
  end

  def header
    text "#{recipe_run_data.recipe.name}", size: 20
    text "#{recipe_run_data.recipe.recipe_type}", size: 20
    text display_weight(recipe_run_data.weight), size: 10
  end

  def products_table
    table(product_data, column_widths: [130, 38, 56, 56]) do
      row(0).style(background_color: PdfReport::HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1).style(align: :center)
    end
  end

  def product_data
    header = ['Product Name', 'Qty', 'Item Wt', 'Total Wt']
    rows = recipe_run_data.products.map do |product|
      [
        product[:product].name,
        product[:quantity],
        display_weight(product[:product].weight_with_unit),
        display_weight(product[:weight])
      ]
    end
    rows.unshift(header)
  end

  def inclusions_table
    move_down 30
    table(inclusions_rows, column_widths: [224, 56]) do
      row(0).style(background_color: PdfReport::HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1).style(align: :center)
    end
  end

  def inclusions_rows
    header = %w(Inclusions Weight)
    rows = recipe_run_data.inclusions.map do |data|
      [data[:recipe].name, display_weight(data[:weight])]
    end
    rows.unshift(header)
  end

  def ingredients_data
    header = ['Ingredient', 'Baker %', 'Weight']
    rows = recipe_run_data.ingredients.map do |ingredient_info|
      [
        ingredient_info[:inclusionable].name,
        ingredient_info[:bakers_percentage],
        display_weight(ingredient_info[:weight])
      ]
    end
    rows.unshift(header)
  end

  def ingredients_table
    table(ingredients_data, column_widths: [169, 56, 56]) do
      row(0).style(background_color: PdfReport::HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1).style(align: :center)
    end
  end

  def nested_recipes_data
    header = ['Nested Recipe', 'Baker %', 'Weight']
    rows = recipe_run_data.nested_recipes.map do |ingredient_info|
      [
        ingredient_info[:inclusionable].name,
        ingredient_info[:bakers_percentage],
        display_weight(ingredient_info[:weight])
      ]
    end
    rows.unshift(header)
  end

  def nested_recipes_table
    move_down 30
    table(nested_recipes_data, column_widths: [169, 56, 56]) do
      row(0).style(background_color: PdfReport::HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1).style(align: :center)
    end
  end

  def deeply_nested_recipes_data
    header = ['Used In Recipe', 'Weight', '% Used']
    rows = recipe_run_data.parent_recipes.map do |recipe_info|
      [
        recipe_info[:parent_recipe].name,
        display_weight(recipe_info[:weight]),
        (recipe_info[:weight] / recipe_run_data.weight * 100).to_f.round(2)
      ]
    end
    rows.unshift(header)
  end

  def deeply_nested_recipes_table
    move_down 30 if recipe_run_data.products.any?
    table(deeply_nested_recipes_data, column_widths: [130, 95, 56]) do
      row(0).style(background_color: PdfReport::HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1).style(align: :center)
    end
  end

  def display_weight(weight)
    weight.round(display_precision).to_s
  end
end
# rubocop:enable Metrics/ClassLength
