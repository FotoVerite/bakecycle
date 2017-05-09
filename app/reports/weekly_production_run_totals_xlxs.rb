class WeeklyProductionRunTotalsXlxs
  def initialize(bakery, date)
    @bakery = bakery
    @date = date
    date_range = (date..date + 6.days)
    @runs = ProductionRun.where(bakery: bakery, date: date_range)
    @weekday_order = date_range.map { |d| d.strftime("%A") }
  end

  def generate
    hash = create_hash_of_products
    rows = create_array_of_rows(hash)
    headers = ["Product Name"]
    @weekday_order.each do |day|
      headers.push(day)
    end
    headers.push("Total")
    p = Axlsx::Package.new
    wb = p.workbook
    wb.add_worksheet(name: "Data Sheet") do |sheet|
      sheet.add_row headers
      rows.each do |row|
        sheet.add_row row
      end
    end
    create_output_string(p)
  end

  # rubocop:disable Metrics/AbcSize

  def create_hash_of_products
    hash = {}
    @runs.each do |r|
      r.run_items.each do |i|
        product_name = i.product.name
        day_name = r.date.strftime("%A")
        hash[product_name] = {} unless hash[product_name]
        # days
        hash[product_name][day_name] = (i.total_quantity + hash[product_name][day_name].to_i)
        # product price
        hash[product_name]["total_products"] = i.total_quantity + hash[product_name]["total_products"].to_i
      end
    end
    hash
  end

  # rubocop:enable Metrics/AbcSize

  def create_array_of_rows(hash)
    array = []
    hash.each do |key, value|
      row = [key]
      @weekday_order.each do |day|
        row.push(value[day] || 0)
      end
      row.push(value["total_products"] || 0)
      array.push(row)
    end
    array
  end

  def create_output_string(p)
    outstrio = StringIO.new
    p.use_shared_strings = true # Otherwise strings don't display in iWork Numbers
    outstrio.write(p.to_stream.read)
    outstrio.string
  end
end
