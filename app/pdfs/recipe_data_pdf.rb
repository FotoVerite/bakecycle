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
    header_section
    main_section
  end

  def header_section
    grid([0, 0], [0, 7]).bounding_box { header_title }
    grid([0, 8], [1, 11]).bounding_box { header_info }
  end

  def main_section
    grid([1, 0], [1, 11]).bounding_box { bowl_count }
    grid([2, 0], [11, 5]).bounding_box { left_section }
    grid([2, 6], [11, 11]).bounding_box { right_section }
  end

  def right_section
    products_table if recipe_run_data.products.any?
    deeply_nested_recipes_table if recipe_run_data.parent_recipes.any?
  end

  def left_section
    ingredients_table
    nested_recipes_table if recipe_run_data.nested_recipes.any?
  end

  def header_title
    text_box recipe_run_data.recipe.name, size: 50, min_font_size: 15, overflow: :shrink_to_fit, width: 380
  end

  def header_info
    header_info_table
  end

  def header_info_table
    table(header_info_data, column_widths: [60, 105], position: :right) do
      column(0).style(borders: [:top, :left, :bottom], align: :right, padding: [4, 4, 2, 2])
      column(1).style(borders: [:top, :right, :bottom], align: :left, padding: [4, 2, 2, 4])
    end
  end

  def header_info_data
    lead_days = ['Lead Days', recipe_run_data.total_lead_days]
    mix = ['Mix', display_date(recipe_run_data.date)]
    bake = ['Bake', display_date(recipe_run_data.finished_date)]
    [lead_days, mix, bake]
  end

  def bowl_count
    table(bowl_data, position: :center, cell_style: { font_style: :bold }) do
      row(0).style(align: :center).valign = :center
      column(0).style(borders: [:top, :left, :bottom], align: :right)
      column(1).style(borders: [:top, :bottom], align: :center)
      column(2).style(borders: [:top, :right, :bottom], align: :left)
    end
  end

  def bowl_data
    [
      [
        { content: "#{recipe_run_data.mix_bowl_count}", rowspan: 2, size: 35 },
        { content: 'X', rowspan: 2, size: 10 },
        { content: "#{display_weight(recipe_run_data.mix_size_with_unit)}", rowspan: 2, size: 15 }
      ]
    ]
  end

  def products_table
    table(product_data, column_widths: [52, 137, 32, 52]) do
      row(0).style(background_color: PdfReport::HEADER_ROW_COLOR)
      column(0).style(align: :center)
      column(2..-1).style(align: :center)
      column(1).style(align: :left)
      row(1..-1).column(2).style(background_color: PdfReport::HEADER_ROW_COLOR)
    end
  end

  def product_data
    header = ['Item Wt', 'Product Name', 'Qty', 'Total Wt']
    product_rows.unshift(header)
  end

  def product_rows
    sorted_recipe_run_date_products.map do |product|
      [
        display_weight(product[:product].weight_with_unit),
        product[:product].name,
        product[:quantity],
        display_weight(product[:weight])
      ]
    end
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
    rows = sorted_parent_recipes.map do |recipe_info|
      [
        recipe_info[:parent_recipe].name.titleize,
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

  def display_date(date)
    date.strftime('%a, %b %d, %Y')
  end

  private

  def sorted_parent_recipes
    @recipe_run_data.parent_recipes.sort_by { |h| h[:parent_recipe][:name].downcase }
  end

  def sorted_recipe_run_date_products
    recipe_run_data.products.sort_by { |product| [product_without_inclusion(product), product[:product].name.downcase] }
  end

  def product_without_inclusion(product)
    product[:product].inclusion ? 1 : 0
  end
end
# rubocop:enable Metrics/ClassLength
