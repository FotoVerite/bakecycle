# frozen_string_literal: true

class GroceryListXlsx
  include XlsxReport

  def initialize(bakery, date)
    @bakery = bakery
    @date = date
    @order_items = []
    @order_items = @bakery.order_items.includes(:order).production_date(date)
  end

  def generate
    p = Axlsx::Package.new
    wb = p.workbook
    styles = wb.styles
    @header = styles.add_style bg_color: "DD", sz: 16, b: true, alignment: { horizontal: :center }
    @client_style = styles.add_style bg_color: "0000FF", fg_color: "FF", sz: 24, alignment: { horizontal: :center }
    weights = {}
    weights = seperate_item_ingredients_into_list(weights, @order_items, @date.strftime("%A").downcase)
    wb.add_worksheet(name: "Grocery List for #{@date}") do |sheet|
      add_rows(weights, sheet)
    end
    create_output_string(p)
  end

  def seperate_item_ingredients_into_list(hash, items, day_of_week)
    items.each do |item|
      next unless item.product.motherdough

      data = CostingRecipeData.new(item.product, item.attributes[day_of_week])
      data.motherdough.items.each do |m_item|
        hash[m_item[:name]] = 0 unless hash[m_item[:name]]
        hash[m_item[:name]] += m_item[:weight].to_g.to_f
      end
      next unless data.inclusion

      data.inclusion.items.each do |i_item|
        hash[i_item[:name]] = 0 unless hash[i_item[:name]]
        hash[i_item[:name]] += i_item[:weight].to_g.to_f
      end
    end
    hash
  end

  def add_rows(weights, sheet)
    # Set Product Type Row
    weights.each_key do |key|
      next unless weights[key].to_i.positive?

      sheet.add_row [key, weights[key]]
    end
  end

end
