# frozen_string_literal: true

class DateSpanProductionRunTotalsXlsx
  def initialize(bakery, start_date, end_date)
    @bakery = bakery
    date_range = (start_date..end_date)
    @runs = ProductionRun.where(bakery: bakery, date: date_range)
  end

  def generate
    hash = create_hash_of_products
    headers = ["Weight", "Product Name"]
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

  def create_hash_of_products
    hash = {}
    @runs.each do |r|
      r.run_items.each do |i|
        product_hash = hash[i.product_type].nil? ? hash[i.product_type] = {} : hash[i.product_type]
        hash_product_info(product_hash, i)
      end
    end
    hash
  end

  def hash_product_info(hash, item)
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
      row.push(value["total_products"] || 0)
      sheet.add_row row
    end
    total_end_row = create_end_row(sheet, start)
    sheet.add_row total_end_row
  end

  def create_end_row(sheet, start)
    end_of = sheet.rows.last.index + 1
    total_row = [nil, nil]
    %w[C D E F G H I J].each do |sum|
      total_row.push("=SUM(#{sum}#{start}:#{sum}#{end_of})")
    end
    total_row
  end

  def create_output_string(page)
    outstrio = StringIO.new
    page.use_shared_strings = true # Otherwise strings don't display in iWork Numbers
    outstrio.write(page.to_stream.read)
    outstrio.string
  end
end
