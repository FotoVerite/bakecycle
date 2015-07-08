class PrefermentDataPage
  include WeightDisplayer

  def initialize(pdf, preferments)
    @pdf = pdf
    @preferments = preferments
    @date = preferments.first.date
  end

  def render
    start_new_page
    page_layout
  end

  private

  def method_missing(method, *args, &block)
    @pdf.send(method, *args, &block)
  end

  def page_layout
    define_grid(columns: 12, rows: 12, gutter: 10)
    header
    body
  end

  def header
    grid([-0.3, 0], [0, 6]).bounding_box { header_title }
    grid([-0.3, 6], [0, 11]).bounding_box { header_date }
  end

  def header_title
    text_box 'Preferments', size: 35, align: :left, valign: :center
  end

  def header_date
    text "#{@date.strftime('%A %B %e, %Y')}", size: 20, align: :right, valign: :center
  end

  def body
    column_box([0, cursor], columns: 2, width: bounds.width) do
      @preferments.each do |recipe|
        preferment_table(recipe)
      end
    end
  end

  def preferment_table(recipe)
    table(preferment_data(recipe), column_widths: [216, 65]) do
      row(0).style(background_color: BasePdfReport::HEADER_ROW_COLOR, font_style: :bold, size: 12, height: 25)
      row(1..-1).style(height: 20, overflow: :shrink_to_fit, min_font_size: 5)
      column(1).style(align: :center)
      row(-2..-1).style(font_style: :bold)
    end
    move_down 10
  end

  def preferment_data(recipe_data)
    header = ["#{recipe_data.recipe.name}", "#{recipe_data.mix_bowl_count}"]
    rows = recipe_data.ingredients.map do |ingredient_info|
      [
        ingredient_info[:inclusionable].name,
        display_weight(recipe_data.bowl_ingredient_weight(ingredient_info))
      ]
    end
    bowl_info = [
      ['Total Bowl', display_weight(recipe_data.total_bowl_weight)],
      ["Total #{recipe_data.recipe.name}", display_weight(recipe_data.weight)]
    ]
    rows += bowl_info
    rows.unshift(header)
  end
end
