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
        table([[preferment_data(recipe)]])
        move_down 10
      end
    end
  end

  private

  def preferment_data(recipe)
    rows = ingredient_rows(recipe)
    rows += [preferment_total_bowl_info(recipe), preferment_total_recipe_weight_info(recipe)]
    rows.unshift(preferment_header(recipe))
  end

  def preferment_header(recipe)
    styles = {
      background_color: BasePdfReport::HEADER_ROW_COLOR, size: 12, font_style: :bold, height: 25
    }
    [
      { content: "#{recipe.recipe.name}", width: 216 }.merge(styles),
      { content: "#{recipe.mix_bowl_count}", align: :center, width: 65 }.merge(styles)
    ]
  end

  def ingredient_rows(recipe)
    recipe.ingredients.map do |ingredient_info|
      [
        { content: ingredient_info[:inclusionable].name }.merge(BasePdfReport::TABLE_STYLE),
        display_weight(recipe.bowl_ingredient_weight(ingredient_info))
          .merge(align: :center).merge(BasePdfReport::TABLE_STYLE)
      ]
    end
  end

  def preferment_total_bowl_info(recipe)
    [
      { content: 'Total Bowl', font_style: :bold }.merge(BasePdfReport::TABLE_STYLE),
      display_weight(recipe.total_bowl_weight)
        .merge(align: :center, font_style: :bold)
        .merge(BasePdfReport::TABLE_STYLE)
    ]
  end

  def preferment_total_recipe_weight_info(recipe)
    [
      { content: "Total #{recipe.recipe.name}", font_style: :bold }.merge(BasePdfReport::TABLE_STYLE),
      display_weight(recipe.weight)
        .merge(align: :center, font_style: :bold)
        .merge(BasePdfReport::TABLE_STYLE)
    ]
  end
end
