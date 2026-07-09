# frozen_string_literal: true

# Pivot layout: one row per product, one column per delivery date, grouped
# into a merged bold section per product_type with a subtotal row -- the
# same grouped/subtotaled shape already used by DateSpanProductionRunTotalsXlsx
# and ClientsPerProductForWeekXlsx, just with dates as the pivoted columns
# instead of weekdays.
class ProductTotalsDateRangeXlsx
  HORIZON_DAYS = 10
  DEFAULT_SOURCE = ProductTotalsQuery::DEFAULT_SOURCE
  SOURCES = ProductTotalsQuery::SOURCES

  def initialize(bakery, date, end_date: nil, source: DEFAULT_SOURCE)
    @bakery = bakery
    @date = date.to_date
    @end_date = (end_date || @date + HORIZON_DAYS.days).to_date
    @source = self.class.normalize_source(source)
  end

  def self.normalize_source(source)
    ProductTotalsQuery.normalize_source(source)
  end

  def generate
    package = Axlsx::Package.new
    workbook = package.workbook
    styles = workbook.styles
    header_style = styles.add_style(bg_color: "EAF6FC", fg_color: "0B5B84", b: true, alignment: { horizontal: :center })
    group_style = styles.add_style(bg_color: "323C46", fg_color: "FFFFFF", b: true, sz: 12)
    subtotal_style = styles.add_style(b: true, bg_color: "F2F3F4")
    last_column = column_letter(header_row.length)

    workbook.add_worksheet(name: "Product Totals") do |sheet|
      sheet.add_row ["Product Totals", "#{@date.iso8601} through #{@end_date.iso8601}"]
      sheet.add_row []
      sheet.add_row(header_row, style: header_style)

      grouped_rows.each do |group|
        sheet.add_row [group[:label]], style: group_style
        sheet.merge_cells("A#{sheet.rows.size}:#{last_column}#{sheet.rows.size}")
        group[:rows].each { |row| sheet.add_row row }
        sheet.add_row group[:subtotal], style: subtotal_style
        sheet.add_row []
      end
    end

    create_output_string(package)
  end

  def header_row
    ["Product"] + date_headers + ["Grand Total"]
  end

  # One entry per product_type, in the model's own enum order (matching menu
  # order elsewhere in the app). Each entry's :rows are the product lines
  # (product name, one quantity per delivery date, row total); :subtotal
  # sums those lines per date plus an overall total.
  def grouped_rows
    pivot.map do |product_type, products|
      rows = products.map do |product, quantities_by_date|
        row_values = delivery_dates.map { |date| quantities_by_date.fetch(date, 0) }
        [product.name] + row_values + [row_values.sum]
      end
      subtotal_values = delivery_dates.each_index.map { |index| rows.sum { |row| row[index + 1] } }
      { label: product_type.titleize, rows: rows, subtotal: ["Subtotal"] + subtotal_values + [subtotal_values.sum] }
    end
  end

  private

  def pivot
    @_pivot ||= begin
      grouped = {}
      totals.each do |delivery_date, product, quantity|
        grouped[product.product_type] ||= {}
        grouped[product.product_type][product] ||= {}
        grouped[product.product_type][product][delivery_date] = quantity
      end
      grouped
        .sort_by { |product_type, _products| Product.product_types.fetch(product_type) }
        .to_h
        .transform_values { |products| products.sort_by { |product, _quantities| product.name } }
    end
  end

  def totals
    @_totals ||= ProductTotalsQuery.new(@bakery, @date, @end_date, source: @source).totals
  end

  def delivery_dates
    (@date..@end_date).to_a
  end

  def date_headers
    delivery_dates.map { |date| date.strftime("%-m/%-d/%y") }
  end

  def column_letter(offset_from_a)
    ("A".."ZZ").to_a[offset_from_a]
  end

  def create_output_string(page)
    outstrio = StringIO.new
    page.use_shared_strings = true
    outstrio.write(page.to_stream.read)
    outstrio.string
  end
end
