# frozen_string_literal: true

class ClientsPerProductForWeekXlsx
  include XlsxReport

  def initialize(bakery, date)
    @bakery = bakery
    @date = date
    @date_range = (date..date + 6.days)
    @orders = Order.where(bakery: bakery).active(date)
    @weekday_order = @date_range.map { |d| d.strftime("%A") }
    @weekday_order_with_date = @date_range.map { |d| d.strftime("%A %m-%d") }
  end

  def generate
    hash = create_hash_of_products
    headers = ["Client"]
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

  def create_hash_of_products
    hash = {}
    @orders.each do |order|
      order.order_items.each do |i|
        client = order.client.name
        product_type = i.product.product_type
        product_hash = hash[product_type].nil? ? hash[product_type] = {} : hash[product_type]
        @weekday_order.each do |day_name|
          hash_product_info(product_hash, i, client, day_name)
        end
      end
    end
    Rails.logger.error "8888"
    Rails.logger.error hash
    hash
  end

  def hash_product_info(hash, item, client, day_name)
    product_name = item.product.name
    day_quantity = item.send(day_name.downcase)
    hash[product_name] = {} unless hash[product_name]
    hash[product_name][client] = { total_quantity: 0 } unless hash[product_name][client]
    client_hash = hash[product_name][client]

    # days
    client_hash[day_name.downcase] = day_quantity
    # product price
    client_hash[:total_quantity] += day_quantity || 0
    hash
  end

  def add_rows(hash, sheet)
    array = []
    # Set Product Type Row
    hash.each do |key, product_hash|
      sheet.add_row [key], style: @header
      sheet.merge_cells("A#{sheet.rows.size}:I#{sheet.rows.size}")
      product_hash.each do |product_name, client_values|
        sheet.add_row [product_name], style: @header
        sheet.merge_cells("A#{sheet.rows.size}:I#{sheet.rows.size}")
        create_client_rows(client_values, sheet)
      end
      sheet.add_row [""]
    end
    array
  end

  def create_client_rows(client_values, sheet)
    start = sheet.rows.size + 1
    client_values.each do |client, values|
      row = []
      row.push(client)
      @weekday_order.each do |day|
        row.push(values[day.downcase] || 0)
      end
      row.push(values[:total_quantity] || 0)
      sheet.add_row row
      row = []
    end
    total_end_row = create_end_row(sheet, start)
    # escape_formulas: false -- axlsx defaults to treating a leading '=' as literal
    # text (CSV-injection guard), so without this the SUM cells rendered the
    # formula source itself instead of a computed total.
    sheet.add_row total_end_row, escape_formulas: false
    sheet.add_row []
  end

  def create_end_row(sheet, start)
    end_of = sheet.rows.size
    total_row = [nil]
    %w[B C D E F G H I].each do |sum|
      total_row.push("=SUM(#{sum}#{start}:#{sum}#{end_of})")
    end
    total_row
  end

end
