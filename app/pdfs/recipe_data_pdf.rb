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
    grid([0, 0], [0, 11]).bounding_box { header_title }
  end

  def main_section
    grid([0.75, 0], [11, 5]).bounding_box { left_section }
    grid([0.75, 6], [11, 11]).bounding_box { right_section }
  end

  def right_section
    products_table if recipe_run_data.products.any?
    parent_recipes_table if recipe_run_data.parent_recipes.any?
    product_tables if products_with_inclusion.any?
  end

  def left_section
    grid([0, 0], [0, 2]).bounding_box { bowl_count }
    grid([0, 2], [0.5, 5]).bounding_box { header_info }

    ingredients_table
    nested_recipes_table if recipe_run_data.nested_recipes.any?
    totals
  end

  def header_title
    text_box recipe_run_data.recipe.name, size: 45, min_font_size: 15, overflow: :shrink_to_fit, width: 380
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
    table(bowl_data, cell_style: { font_style: :bold }) do
      row(0).style(align: :right).valign = :center
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
    table(product_data, column_widths: [52, 145, 32, 52]) do
      row(0).style(background_color: BasePdfReport::HEADER_ROW_COLOR)
      column(0).style(align: :center)
      column(2..-1).style(align: :center)
      column(1).style(align: :left)
      row(1..-1).column(2).style(background_color: BasePdfReport::HEADER_ROW_COLOR)
    end
  end

  def product_data
    header = ['Item Wt', 'Product Name', 'Qty', 'Total Wt']
    product_rows.unshift(header)
  end

  def product_rows
    sorted_recipe_run_date_products.map do |product|
      [
        display_weight(product[:product].weight_with_unit.to_kg),
        product[:product].name,
        product[:quantity],
        display_weight(product[:weight])
      ]
    end
  end

  def product_tables
    products_with_inclusion.each do |product|
      move_down 10
      table(product_with_inclusion_data(product), column_widths: [186, 95]) do
        row(0).style(background_color: BasePdfReport::HEADER_ROW_COLOR)
        column(0).style(align: :left)
        column(1).style(align: :center)
      end
    end
  end

  def product_with_inclusion_data(product)
    inclusion = inclusion_for_product(product)

    header = [product[:product].name, display_weight(product[:weight])]
    dough_row = ['Dough', display_weight(product[:dough_weight])]
    inclusion_row = [inclusion[:recipe].name, display_weight(inclusion[:weight])]
    [header, dough_row, inclusion_row]
  end

  def ingredients_data
    header = ['Ingredient', 'Baker %', 'Wt / Bowl']
    rows = recipe_run_data.ingredients.map do |ingredient_info|
      [
        ingredient_info[:inclusionable].name,
        ingredient_info[:bakers_percentage],
        display_weight(bowl_ingredient_weight(ingredient_info))
      ]
    end
    rows.unshift(header)
  end

  def ingredients_table
    table(ingredients_data, column_widths: [169, 51, 61]) do
      row(0).style(background_color: BasePdfReport::HEADER_ROW_COLOR, overflow: :shrink_to_fit)
      column(0).style(align: :left)
      column(1..2).style(align: :center)
    end
  end

  def nested_recipes_data
    header = ['Nested Recipe', 'Baker %', 'Wt / Bowl']
    rows = recipe_run_data.nested_recipes.map do |ingredient_info|
      [
        ingredient_info[:inclusionable].name,
        ingredient_info[:bakers_percentage],
        display_weight(bowl_ingredient_weight(ingredient_info))
      ]
    end
    rows.unshift(header)
  end

  def nested_recipes_table
    move_down 20
    table(nested_recipes_data, column_widths: [169, 51, 61]) do
      row(0).style(background_color: BasePdfReport::HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1..2).style(align: :center)
    end
  end

  def parent_recipes_data
    header = ['Used In Recipe', 'Weight']
    rows = sorted_parent_recipes.map do |recipe_info|
      [
        recipe_info[:parent_recipe].name.titleize,
        display_weight(recipe_info[:weight])
      ]
    end
    rows.unshift(header)
  end

  def parent_recipes_table
    move_down 20 if recipe_run_data.products.any?
    table(parent_recipes_data, column_widths: [186, 95]) do
      row(0).style(background_color: BasePdfReport::HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1..2).style(align: :center)
    end
  end

  def display_weight(weight)
    weight.round(display_precision).to_s
  end

  def display_date(date)
    date.strftime('%a, %b %d, %Y')
  end

  def totals
    move_down 10
    table(totals_info, position: :right, column_widths: [215, 61]) do
      cells.borders = []
      column(0).style(font_style: :bold, align: :right)
      column(1).style(align: :center)
      column(1).borders = [:top, :right, :bottom, :left]
    end
  end

  def totals_info
    [
      ['Bowl Weight', display_weight(total_bowl_weight)],
      ["Bowl Weight x #{recipe_run_data.mix_bowl_count}", display_weight(recipe_run_data.weight)]
    ]
  end

  private

  def bowl_ingredient_weight(ingredient_info)
    return Unitwise(0, :kg) if ingredient_info[:weight] == Unitwise(0, :kg)
    ingredient_info[:weight] / recipe_run_data.mix_bowl_count
  end

  def total_bowl_weight
    return Unitwise(0, :kg) if recipe_run_data.weight == Unitwise(0, :kg)
    recipe_run_data.weight / recipe_run_data.mix_bowl_count
  end

  def sorted_parent_recipes
    recipe_run_data.parent_recipes.sort_by { |h| h[:parent_recipe][:name].downcase }
  end

  def sorted_recipe_run_date_products
    recipe_run_data.products.sort_by { |product| [product_without_inclusion(product), product[:product].name.downcase] }
  end

  def product_without_inclusion(product)
    product[:product].inclusion ? 1 : 0
  end

  def products_with_inclusion
    sorted_recipe_run_date_products.select { |product| product[:product].inclusion }
  end

  def inclusion_for_product(product)
    recipe_run_data.inclusions.detect { |i| i[:product] == product[:product] }
  end
end
# rubocop:enable Metrics/ClassLength
