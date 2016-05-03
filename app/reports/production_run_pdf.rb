class ProductionRunPdf < BasePdfReport
  include WeightDisplayer
  attr_reader :run_data

  def initialize(run_data)
    @run_data = run_data
    @bakery = run_data.bakery.decorate
    super()
  end

  private

  def setup
    header_stamp
    production_run_info
    products
    recipes
    timestamp
    run_stamp
  end

  def header_stamp
    stamp_or_create("header") { header }
  end

  def run_stamp
    repeat :all do
      bounding_box([0, 0], width: (bounds.width / 2.0), height: 10) do
        text run_label, size: 8, style: :bold, align: :left
      end
    end
  end

  def run_label
    return "Production Run ##{run_data.id}" if run_data.id
    "Production Run PROJECTION"
  end

  def header
    bounding_box([0, cursor], width: 260, height: 60) { bakery_logo_display(@bakery) }
    grid([0, 5.5], [0, 8]).bounding_box { bakery_info(@bakery) }
    move_down 15
  end

  def production_run_info
    font_size 10
    text run_label
    text "#{run_data.start_date} - #{run_data.end_date}"
    move_down 15
  end

  def recipes
    if @bakery.group_preferments
      recipe_data_with_single_preferment_page
    else
      recipe_data_with_preferments
    end
  end

  def products
    run_data.products.each do |product_type|
      products_table(product_type)
      move_down 15
    end
  end

  def products_table(product_type)
    table(
      product_information_row(product_type),
      column_widths: [422, 120, 30],
      header: true,
      cell_style: BasePdfReport::TABLE_STYLE
    ) do
      row(0).style(background_color: HEADER_ROW_COLOR)
      column(0).style(align: :left)
      column(1..-1).style(align: :center)
    end
  end

  def product_information_row(product_type)
    header = [product_type.first.titleize.to_s, "Qty", nil]
    rows = product_type[1].map do |run_item|
      [
        run_item.product.name,
        run_item.total_quantity,
        nil
      ]
    end
    rows.unshift(header)
  end

  def recipe_data_with_single_preferment_page
    run_data.recipes_without_preferments.each do |motherdough|
      RecipeDataPage.new(self, motherdough).render
    end
    render_preferment_pages
  end

  def recipe_data_with_preferments
    run_data.recipes.each do |motherdough|
      RecipeDataPage.new(self, motherdough).render
    end
  end

  def render_preferment_pages
    PrefermentDataPage.new(self, run_data.preferments).render if run_data.preferments.any?
  end
end
