class DailyTotalPdf < BasePdfReport
  def initialize(bakery, date, show_routes = true)
    @recipes = ProductCounter.new(bakery, date)
    @show_routes = show_routes
    super()
  end

  def setup
    header
    body
    footer
  end

  def header
    repeat :all do
      header_left
      header_right
    end
  end

  def header_left
    bounding_box([bounds.left, bounds.top], width: (bounds.width / 2.0)) do
      text "Daily Totals", size: 20, align: :left
    end
  end

  def header_right
    bounding_box([288, bounds.top], width: (bounds.width / 2.0)) do
      text @recipes.date_formatted, size: 20, align: :right
    end
  end

  def body
    bounding_box([bounds.left, bounds.top - 40], width: bounds.width, height: bounds.height - 50) do
      information
    end
  end

  def information
    @recipes.product_types.each do |type|
      move_down 20
      text invert_product_type(type).titleize, size: 20
      table(information_data(type), column_widths: column_width_sizes, header: true, row_colors: %w(FFFFFF E3E3E3)) do
        row(0).style(background_color: HEADER_ROW_COLOR, size: 10)
        row(0..-1).column(1..-1).style(align: :center)
      end
    end
  end

  def column_width_sizes
    item_name_column_width = 180.0

    array = []
    columns = information_header[0].count
    (0...columns).each do |x|
      next array << item_name_column_width if x == 0
      array << (bounds.width - item_name_column_width) / (columns - 1)
    end
    array
  end

  def information_data(type)
    data = information_header
    data += product_items(type)
    data
  end

  def information_header
    data = [%w(Item Total Overbake)]
    if @show_routes
      @recipes.routes.each do |route|
        data[0] << route.name.titleize
      end
    end
    data
  end

  def product_items(type)
    recipe_products(type).map do |product|
      array = [product.name, total_count(product), overbake_count(product)]
      array += route_counts(product) if @show_routes
      array
    end
  end

  private

  def recipe_products(type)
    @recipes.products.where(product_type: type)
  end

  def route_counts(product)
    @recipes.routes.map do |route|
      product_counts[product.id][route.id] || 0
    end
  end

  def total_count(product)
    product_counts[product.id][:total]
  end

  def overbake_count(product)
    product_counts[product.id][:overbake_count]
  end

  def product_counts
    @recipes.product_counts
  end

  def invert_product_type(type)
    Product.product_types.invert[type]
  end
end
