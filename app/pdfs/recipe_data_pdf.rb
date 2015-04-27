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

    grid([0, 0], [1, 5]).bounding_box do
      header
    end
    grid([0, 6], [1, 11]).bounding_box do
      header_table
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
    deeply_nested_recipes_table if recipe_run_data.parent_recipes.any?
  end

  def left_section
    ingredients_table
    nested_recipes_table if recipe_run_data.nested_recipes.any?
  end

  def header
    text "#{recipe_run_data.recipe.name}", size: 20
    text "Type: #{recipe_run_data.recipe.recipe_type.capitalize}", size: 15
  end

  def header_table
    table(header_data, column_widths: [93, 93, 93]) do
      row(0).style(background_color: PdfReport::HEADER_ROW_COLOR)
      column(0..2).style(align: :center)
    end
  end

  def header_data
    header = ['Total Weight', 'Bowl Size', 'Bowl Count']
    data = [
      display_weight(recipe_run_data.weight),
      "#{recipe_run_data.recipe.mix_size} #{recipe_run_data.recipe.mix_size_unit}",
      recipe_run_data.mix_bowl_count
    ]
    [header, data]
  end

  def products_table
    table(product_data, column_widths: [130, 38, 56, 56]) do
      row(0).style(background_color: PdfReport::HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1..3).style(align: :center)
    end
  end

  def product_data
    header = ['Product Name', 'Qty', 'Item Wt', 'Total Wt']
    product_rows.unshift(header)
  end

  def product_rows
    rows = []
    recipe_run_data.products.each do |product|
      rows << [
        product[:product].name,
        product[:quantity],
        display_weight(product[:product].weight_with_unit),
        display_weight(product[:weight])
      ]

      rows << product_parts_table(product)
    end
    rows
  end

  def indent_cell
    make_cell(content: '', background_color: PdfReport::HEADER_ROW_COLOR)
  end

  def motherdough_row(product)
    dough_name = make_cell(
      content: "#{recipe_run_data.recipe.name} dough",
      background_color: PdfReport::INDENTED_ROW_COLOR
    )
    dough_weight = make_cell(
      content: display_weight(product[:dough_weight]),
      background_color: PdfReport::INDENTED_ROW_COLOR
    )

    [indent_cell, dough_name, dough_weight]
  end

  def inclusion_row(product)
    inclusion = recipe_run_data.inclusions.detect { |i| i[:product] == product[:product] }
    return unless inclusion
    name = make_cell(content: inclusion[:recipe].name, background_color: PdfReport::INDENTED_ROW_COLOR)
    weight = make_cell(content: display_weight(inclusion[:weight]), background_color: PdfReport::INDENTED_ROW_COLOR)
    [indent_cell, name, weight]
  end

  def product_parts_table(product)
    table_data = [motherdough_row(product), inclusion_row(product)].compact
    [colspan: 4, content: make_table(table_data, column_widths: [10, 214, 56])]
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
    move_down 20
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
    move_down 20 if recipe_run_data.products.any?
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
