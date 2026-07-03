# frozen_string_literal: true

# One workbook, four sheets -- Retail Bake, Wholesale Bake, Pull/Prep List,
# Viennoiserie Pick -- matching the multi-worksheet precedent already
# established by SortedPackListXlsx. Blank "Short"/"Extra"/"Checked" columns
# are literal nil cells for staff to fill in by hand, the same pattern
# packing_slip_page.rb's "Pack Check" column already uses.
class BakeListXlsx
  def initialize(bakery, bake_date)
    @bakery = bakery
    @bake_date = bake_date.to_date
    @data = BakeListData.new(@bakery, @bake_date)
  end

  def generate
    package = Axlsx::Package.new
    workbook = package.workbook
    styles = workbook.styles
    header_style = styles.add_style(bg_color: "EAF6FC", fg_color: "0B5B84", b: true, alignment: { horizontal: :center })

    add_sheet(workbook, "Retail Bake", header_style, ["Product", "Qty", "Trays", "Short", "Extra"], retail_rows)
    add_sheet(workbook, "Wholesale Bake", header_style, ["Product", "Qty", "Trays", "Short", "Extra"], wholesale_rows)
    add_sheet(workbook, "Pull-Prep List", header_style, ["Product", "Qty", "Trays", "Checked"], pull_list_rows)
    add_sheet(workbook, "Viennoiserie Pick", header_style, ["Product", "Qty", "Trays"], viennoiserie_rows)

    create_output_string(package)
  end

  # Public row-builder methods, following ProductTotalsDateRangeXlsx's
  # testability convention: specs assert on these directly, never on parsed
  # xlsx bytes.
  def retail_rows
    @data.retail_items.map { |row| [row[:product].name, row[:quantity], row[:trays], nil, nil] }
  end

  def wholesale_rows
    @data.wholesale_items.map { |row| [row[:product].name, row[:quantity], row[:trays], nil, nil] }
  end

  def pull_list_rows
    @data.pull_list_items.map { |row| [row[:product].name, row[:quantity], row[:trays], nil] }
  end

  def viennoiserie_rows
    @data.viennoiserie_pick_items.map { |row| [row[:product].name, row[:quantity], row[:trays]] }
  end

  private

  def add_sheet(workbook, name, header_style, headers, rows)
    workbook.add_worksheet(name: name) do |sheet|
      sheet.add_row [name, @bake_date.iso8601]
      sheet.add_row []
      sheet.add_row(headers, style: header_style)
      rows.each { |row| sheet.add_row row }
    end
  end

  def create_output_string(page)
    outstrio = StringIO.new
    page.use_shared_strings = true
    outstrio.write(page.to_stream.read)
    outstrio.string
  end
end
