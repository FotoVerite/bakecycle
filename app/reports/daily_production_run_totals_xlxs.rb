class DailyProductionRunTotalsXlxs
  def initialize(bakery, date)
    @bakery = bakery
    @date = date
    @runs = ProductionRun.where(bakery: bakery, date: date)
  end

  def generate
    hash, total = create_hash_of_products
    headers = ["Weight", "Product Name"]
    headers.push("Total")
    p = Axlsx::Package.new
    wb = p.workbook
    styles = wb.styles
    @header = styles.add_style bg_color: "DD", sz: 16, b: true, alignment: { horizontal: :center }
    wb.add_worksheet(name: "Data Sheet") do |sheet|
      sheet.add_row headers
      add_rows(hash, sheet, total)
    end
    create_output_string(p)
   end

  # rubocop:disable Metrics/AbcSize

  def create_hash_of_products
    hash = {}
    total = 0
    @runs.each do |r|
      r.run_items.each do |i|
        day_name = r.date.strftime("%A")
        product_hash = hash[i.product_type].nil? ? hash[i.product_type] = {} : hash[i.product_type]
        hash_product_info(product_hash, i, day_name)
        total += i.total_quantity
      end
    end
    [hash, total]
  end

  def hash_product_info(hash, item, _day_name)
    product_name = item.product.name
    total_quantity = item.total_quantity
    hash[product_name] = {} unless hash[product_name]
    unless hash[product_name]["weight"]
      hash[product_name]["weight"] = format(
        "%0.3f", item.product.weight_with_unit.to_kg.round(3)
      ) + " kg"
    end
    # product price
    hash[product_name]["total_products"] = total_quantity + hash[product_name]["total_products"].to_i
  end

  # rubocop:enable Metrics/AbcSize

  def add_rows(hash, sheet, total)
    # Set Product Type Row
    hash.each do |key, product_values|
      sheet.add_row [key], style: @header
      sheet.merge_cells("A#{sheet.rows.last.index + 1}:C#{sheet.rows.last.index + 1}")
      sheet.add_row [""]
      create_product_rows(product_values, sheet)
      sheet.add_row [""]
    end
    sheet.add_row ["Total"], style: @header
    sheet.merge_cells("A#{sheet.rows.last.index + 1}:C#{sheet.rows.last.index + 1}")
    sheet.add_row [""]
    sheet.add_row ["", "", total]
  end

  def create_product_rows(product_values, sheet)
    start = sheet.rows.last.index + 2
    product_values.each do |key, value|
      row = [value["weight"]]
      row.push(key)
      row.push(value["total_products"] || 0)
      sheet.add_row row
    end
    total_end_row = create_end_row(sheet, start)
    sheet.add_row total_end_row
  end

  def create_end_row(sheet, start)
    end_of = sheet.rows.last.index + 1
    total_row = [nil, nil]
    %w(C).each do |sum|
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
