class WeeklyProductionRunTotalsXlxs
  def initialize(bakery, date)
    @bakery = bakery
    @date = date
    date_range = (date..date + 6.days)
    @runs = ProductionRun.where(bakery: bakery, date: date_range)
    @weekday_order = date_range.map { |d| d.strftime("%A") }
    @weekday_order_with_date = date_range.map { |d| d.strftime("%A %m-%d") }
  end

  def generate
    hash = create_hash_of_products
    headers = ["Weight", "Product Name"]
    @weekday_order_with_date.each do |day|
      headers.push(day)
    end
    headers.push("Total")
    p = Axlsx::Package.new
    wb = p.workbook
    styles = wb.styles
    @header = styles.add_style bg_color: "DD", sz: 16, b: true, alignment: { horizontal: :center }
    wb.add_worksheet(name: "Data Sheet") do |sheet|
      sheet.add_row headers
      add_rows(hash, sheet)
    end
    create_output_string(p)
  end

  # rubocop:disable Metrics/AbcSize

  def create_hash_of_products
    hash = {}
    @runs.each do |r|
      r.run_items.each do |i|
        day_name = r.date.strftime("%A")
        product_hash = hash[i.product_type].nil? ? hash[i.product_type] = {} : hash[i.product_type]
        hash_product_info(product_hash, i, day_name)
      end
    end
    hash
  end

  def hash_product_info(hash, item, day_name)
    product_name = item.product.name
    total_quantity = item.total_quantity
    hash[product_name] = {} unless hash[product_name]
    hash[product_name]["weight"] = format(
      "%0.3f", item.product.weight_with_unit.to_kg.round(3)
    ) + " kg" unless hash[product_name]["weight"]
    # days
    hash[product_name][day_name] = (total_quantity + hash[product_name][day_name].to_i)
    # product price
    hash[product_name]["total_products"] = total_quantity + hash[product_name]["total_products"].to_i
  end

  # rubocop:enable Metrics/AbcSize

  def add_rows(hash, sheet)
    array = []
    # Set Product Type Row
    hash.each do |key, product_values|
      sheet.add_row [key], style: @header
      sheet.merge_cells("A#{sheet.rows.last.index + 1}:J#{sheet.rows.last.index + 1}")
      sheet.add_row [""]
      create_product_rows(product_values, sheet)
      sheet.add_row [""]
    end
    array
  end

  def create_product_rows(product_values, sheet)
    start = sheet.rows.last.index + 2
    product_values.each do |key, value|
      row = [value["weight"]]
      row.push(key)
      @weekday_order.each do |day|
        row.push(value[day] || 0)
      end
      row.push(value["total_products"] || 0)
      sheet.add_row row
    end
    total_end_row = create_end_row(sheet, start)
    sheet.add_row total_end_row
  end

  def create_end_row(sheet, start)
    end_of = sheet.rows.last.index + 1
    total_row = [nil, nil]
    %w(C D E F G H I J).each do |sum|
      total_row.push("=SUM(#{sum}#{start}:#{sum}#{end_of})")
    end
    total_row
  end

  def create_output_string(p)
    outstrio = StringIO.new
    p.use_shared_strings = true # Otherwise strings don't display in iWork Numbers
    outstrio.write(p.to_stream.read)
    outstrio.string
  end
end
