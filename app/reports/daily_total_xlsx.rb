class DailyTotalXlsx
  def initialize(bakery, date, show_routes = true)
    @bakery = bakery
    @date = date
    @recipes = ProductCounter.new(bakery, date)
    @show_routes = show_routes
  end

  def information_header
    data = %w[Item Total Overbake]
    if @show_routes
      @recipes.routes.each do |route|
        data << route.name.titleize
      end
    end
    data
  end

  def generate
    p = Axlsx::Package.new
    wb = p.workbook
    styles = wb.styles
    @header = styles.add_style bg_color: "DD", sz: 16, b: true, alignment: { horizontal: :left }
    wb.add_worksheet(name: "Daily Totals for #{@date}") do |sheet|
      if (@show_routes)
        sheet.add_row(
          information_header, header: @header,
        )
      else
        sheet.add_row(
          information_header, header: @header,
        )
      end
      add_rows(@recipes.products, sheet)
    end
    create_output_string(p)
  end

  def add_rows(products, sheet)
    # Set Product Type Row
    products.each do |p|
      data = [
        p.name,
        @recipes.product_counts[p.id][:total],
        @recipes.product_counts[p.id][:overbake_count],
      ]
      if @show_routes
        @recipes.routes.map do |route|
          data.push(@recipes.product_counts[p.id][route.id] || 0)
        end
      end
      sheet.add_row data
    end
  end

  def create_output_string(page)
    outstrio = StringIO.new
    page.use_shared_strings = true # Otherwise strings don't display in iWork Numbers
    outstrio.write(page.to_stream.read)
    outstrio.string
  end
end
