# frozen_string_literal: true

class WeeklyClientTotalsXlsx
  def initialize(bakery, date)
    @bakery = bakery
    @date = date
    date_range = (date..date + 6.days)
    @shipments = Shipment.where(bakery: bakery, date: date_range).order("client_name ASC") || []
    @weekday_order = date_range.map { |d| d.strftime("%A") }
    @weekday_order_with_date = date_range.map { |d| d.strftime("%A %m-%d") }
  end

  def generate
    headers = ["Weight", "Product Name"]
    @weekday_order_with_date.each do |day|
      headers.push(day)
    end
    headers.push("Total")
    @clients = create_hash_of_clients
    create_hash_of_products
    p = Axlsx::Package.new
    wb = p.workbook
    styles = wb.styles
    @header = styles.add_style bg_color: "DD", sz: 16, b: true, alignment: { horizontal: :center }
    @client_style = styles.add_style bg_color: "0000FF", fg_color: "FF", sz: 24, alignment: { horizontal: :center }
    wb.add_worksheet(name: "Data Sheet") do |sheet|
      sheet.add_row headers
      add_rows(@clients, sheet, 0)
    end
    create_output_string(p)
  end

  def create_hash_of_clients
    hash = {}
    @shipments.each do |s|
      name = s.client.name
      if hash[name].nil?
        hash[name] = {}
        hash[name][:items] = []
      end
      items = s.shipment_items
      items.map { |i| i.date = s.date.strftime("%A") }
      hash[name][:items] += items
      hash[name][:items].flatten
    end
    hash
  end

  def create_hash_of_products
    @clients.each do |k, client_hash|
      hash = {}
      total = 0
      client_hash[:items].each do |i|
        day_name = i.date
        product = i.product
        product_hash = hash[product.product_type].nil? ? hash[product.product_type] = {} : hash[product.product_type]
        hash_product_info(product_hash, i, day_name)
        total += i.product_quantity
      end
      @clients[k][:products] = hash
      @clients[k][:total] = total
    end
  end

  def hash_product_info(hash, item, day_name)
    product_name = item.product.name
    total_quantity = item.product_quantity
    hash[product_name] = {} unless hash[product_name]
    unless hash[product_name]["weight"]
      hash[product_name]["weight"] = "#{format('%0.3f', item.product.weight_with_unit.to_kg.round(3))} kg"
    end
    hash[product_name]["total_products"] = total_quantity + hash[product_name]["total_products"].to_i
    hash[product_name][day_name] = (total_quantity + hash[product_name][day_name].to_i)
  end

  def add_rows(hash, sheet, _total = 0)
    # Set Product Type Row
    hash.each_key do |client|
      sheet.add_row [client], style: @client_style
      sheet.merge_cells("A#{sheet.rows.size}:J#{sheet.rows.size}")
      next unless hash[client][:products]

      hash[client][:products].each do |key, product_values|
        sheet.add_row [key], style: @header
        sheet.merge_cells("A#{sheet.rows.size}:J#{sheet.rows.size}")
        sheet.add_row ["", "", ""]
        create_product_rows(product_values, sheet)
      end
      sheet.add_row ["Total"], style: @header
      sheet.merge_cells("A#{sheet.rows.size}:J#{sheet.rows.size}")
      sheet.add_row ["", "", "", "", "", "", "", "", "", ""]
      sheet.add_row ["", "", "", "", "", "", "", "", "", hash[client][:total]]
      sheet.add_row ["", "", "", "", "", "", "", "", "", ""]
    end
  end

  def create_product_rows(product_values, sheet)
    start = sheet.rows.size + 1
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
    end_of = sheet.rows.size
    total_row = [nil, nil]
    %w[C].each do |sum|
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
