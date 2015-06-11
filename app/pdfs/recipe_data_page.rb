# rubocop:disable Metrics/ClassLength
class RecipeDataPage
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
    grid([1, 0], [11, 5]).bounding_box { left_section }
    grid([1, 6], [11, 11]).bounding_box { right_section }
  end

  def right_section
    products_table
    parent_recipes_table
    inclusion_tables
  end

  def left_section
    grid([0, 0], [0.4, 2]).bounding_box { bowl_count }
    grid([0, 2], [0.4, 5]).bounding_box { header_info }
    ingredients_table
    nested_recipes_table
    totals
  end

  def header_title
    text_box recipe_run_data.recipe.name, size: 45, min_font_size: 15, overflow: :shrink_to_fit, width: 380
  end

  def header_info
    header_info_table
  end

  def header_info_table
    table(header_info_data, column_widths: [60, 105], position: :right, cell_style: BasePdfReport::TABLE_STYLE) do
      column(0).style(borders: [:top, :left, :bottom], align: :right)
      column(1).style(borders: [:top, :right, :bottom], align: :left)
    end
  end

  def header_info_data
    lead_days = ['Lead Days', recipe_run_data.total_lead_days]
    mix = ['Mix', display_date(recipe_run_data.date)]
    bake = ['Bake', display_date(recipe_run_data.finished_date)]
    [lead_days, mix, bake]
  end

  def bowl_count
    table(bowl_data, cell_style: { height: 60, font_style: :bold }) do
      row(0).style(align: :right).valign = :center
      column(0).style(borders: [:top, :left, :bottom], align: :right)
      column(1).style(borders: [:top, :bottom], align: :center)
      column(2).style(borders: [:top, :right, :bottom], align: :left)
    end
  end

  def bowl_data
    [
      [
        { content: "#{recipe_run_data.mix_bowl_count}", size: 35 },
        { content: 'X', size: 10 },
        { content: "#{display_weight(recipe_run_data.mix_size_with_unit)}", size: 15 }
      ]
    ]
  end

  def products_table
    return if recipe_run_data.products.empty?
    table(product_data, column_widths: [52, 145, 32, 52], cell_style: BasePdfReport::TABLE_STYLE) do
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
    recipe_run_data.sorted_recipe_run_date_products.map do |product|
      [
        display_weight(product[:product].weight_with_unit.to_kg),
        product[:product].name,
        product[:quantity],
        display_weight(product[:weight])
      ]
    end
  end

  def inclusion_tables
    return if recipe_run_data.inclusions.empty?
    recipe_run_data.add_recipe_inclusions_info
    recipe_run_data.inclusions_info.each do |inclusion_info|
      move_down 10
      table(inclusion_data(inclusion_info), column_widths: [229, 52], cell_style: BasePdfReport::TABLE_STYLE) do
        row(0).style(background_color: BasePdfReport::HEADER_ROW_COLOR)
        column(0).style(align: :left)
        column(1).style(align: :center)
      end
    end
  end

  def inclusion_data(inclusion_info)
    rows = [
      [inclusion_info[:inclusion].name, display_weight(total_inclusion_weight(inclusion_info))],
      [inclusion_info[:dough].name, display_weight(total_dough_weight(inclusion_info))]
    ]
    inclusion_ingredient_rows(inclusion_info).each { |ingredient_row| rows << ingredient_row }
    rows << ['Total Product Weight', display_weight(inclusion_info[:total_product_weight])]
  end

  def inclusion_ingredient_rows(inclusion_info)
    inclusion_info[:ingredients].map do |ingredient|
      [ingredient[:ingredient].name, display_weight(ingredient[:weight])]
    end
  end

  def total_inclusion_weight(inclusion_info)
    inclusion_info[:total_inclusion_weight]
  end

  def total_dough_weight(inclusion_info)
    inclusion_info[:total_dough_weight]
  end

  def ingredients_data
    header = ['Ingredient', 'Baker %', 'Wt / Bowl']
    rows = recipe_run_data.ingredients.map do |ingredient_info|
      [
        ingredient_info[:inclusionable].name,
        ingredient_info[:bakers_percentage],
        display_weight(recipe_run_data.bowl_ingredient_weight(ingredient_info))
      ]
    end
    rows.unshift(header)
  end

  def ingredients_table
    table(ingredients_data, column_widths: [169, 51, 61], cell_style: BasePdfReport::TABLE_STYLE) do
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
        display_weight(recipe_run_data.bowl_ingredient_weight(ingredient_info))
      ]
    end
    rows.unshift(header)
  end

  def nested_recipes_table
    return if recipe_run_data.nested_recipes.empty?
    move_down 15
    table(nested_recipes_data, column_widths: [169, 51, 61], cell_style: BasePdfReport::TABLE_STYLE) do
      row(0).style(background_color: BasePdfReport::HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1..2).style(align: :center)
    end
  end

  def parent_recipes_data
    header = ['Used In Recipe', 'Weight']
    rows = recipe_run_data.sorted_parent_recipes.map do |recipe_info|
      [
        recipe_info[:parent_recipe].name.titleize,
        display_weight(recipe_info[:weight])
      ]
    end
    rows.unshift(header)
  end

  def parent_recipes_table
    return if recipe_run_data.parent_recipes.empty?
    move_down 15 if recipe_run_data.products.any?
    table(parent_recipes_data, column_widths: [186, 95], cell_style: BasePdfReport::TABLE_STYLE) do
      row(0).style(background_color: BasePdfReport::HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1..2).style(align: :center)
    end
  end

  def display_date(date)
    date.strftime('%a, %b %d, %Y')
  end

  def totals
    move_down 10
    table(totals_info, position: :right, column_widths: [215, 61], cell_style: BasePdfReport::TABLE_STYLE) do
      cells.borders = []
      column(0).style(font_style: :bold, align: :right)
      column(1).style(align: :center)
      column(1).borders = [:top, :right, :bottom, :left]
    end
  end

  def totals_info
    [
      ['Bowl Weight', display_weight(recipe_run_data.total_bowl_weight)],
      ["Bowl Weight x #{recipe_run_data.mix_bowl_count}", display_weight(recipe_run_data.weight)]
    ]
  end
end

private

def display_weight(weight)
  weight.round(display_precision).to_s
end
# rubocop:enable Metrics/ClassLength
