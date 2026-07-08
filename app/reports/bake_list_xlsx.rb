# frozen_string_literal: true

# One workbook, reference-style sheets -- Retail Bread, Wholesale Bread,
# Vienn Pick, and Pull/Prep List -- matching the multi-worksheet precedent
# already established by SortedPackListXlsx. Blank check/count columns are
# literal nil cells for staff to fill in by hand.
class BakeListXlsx
  delegate :retail_sections, :wholesale_sections, :retail_clients, to: :@data

  def initialize(bakery, bake_date)
    @bakery = bakery
    @bake_date = bake_date.to_date
    @data = BakeListData.new(@bakery, @bake_date)
  end

  def generate
    package = Axlsx::Package.new
    workbook = package.workbook
    styles = workbook.styles
    report_styles = {
      title: styles.add_style(b: true, sz: 16, alignment: { horizontal: :center }),
      section: styles.add_style(bg_color: "B7B7B7", b: true, sz: 14, alignment: { horizontal: :center }),
      header: styles.add_style(bg_color: "D9D9D9", b: true, alignment: { horizontal: :center })
    }

    add_retail_sheet(workbook, report_styles)
    add_wholesale_sheet(workbook, report_styles)
    add_viennoiserie_sheet(workbook, report_styles)
    add_pull_list_sheet(workbook, report_styles)

    create_output_string(package)
  end

  # Public row-builder methods, following ProductTotalsDateRangeXlsx's
  # testability convention: specs assert on these directly, never on parsed
  # xlsx bytes.
  def retail_rows
    retail_sections.flat_map do |section|
      section[:rows].map do |row|
        [row[:product].name, row[:quantity]] + retail_clients.map { |client| row[:client_quantities][client].to_i }
      end
    end
  end

  def wholesale_rows
    wholesale_sections.flat_map do |section|
      section[:rows].map { |row| [row[:product].name, row[:quantity], nil, nil] }
    end
  end

  def pull_list_rows
    @data.pull_list_items.map { |row| [row[:product].name, row[:quantity], row[:trays], nil] }
  end

  def viennoiserie_rows
    @data.viennoiserie_pick_items.map do |row|
      total_trays, total_pieces = tray_parts(row[:product], row[:quantity])
      wholesale_trays, wholesale_pieces = tray_parts(row[:product], row[:wholesale_quantity])
      retail_trays, retail_pieces = tray_parts(row[:product], row[:retail_quantity])

      [
        row[:product].name,
        total_trays, total_pieces,
        wholesale_trays, wholesale_pieces, nil, nil,
        retail_trays, retail_pieces, nil, nil
      ]
    end
  end

  private

  def add_retail_sheet(workbook, styles)
    config = { title: "RETAIL", headers: %w[Item Total] + retail_clients.map(&:name), sections: retail_sections }
    add_sectioned_sheet(workbook, "Retail Bread", styles, config) do |row|
      [row[:product].name, row[:quantity]] + retail_clients.map { |client| row[:client_quantities][client].to_i }
    end
  end

  def add_wholesale_sheet(workbook, styles)
    config = { title: "WHOLESALE", headers: %w[Item Total MISSING EXTRA], sections: wholesale_sections }
    add_sectioned_sheet(workbook, "Wholesale Bread", styles, config) do |row|
      [row[:product].name, row[:quantity], nil, nil]
    end
  end

  def add_sectioned_sheet(workbook, sheet_name, styles, config)
    workbook.add_worksheet(name: sheet_name) do |sheet|
      sheet.add_row ["Bake List #{@bake_date.strftime('%A, %-m/%-d')}", nil, nil, sheet_name]
      sheet.add_row [config.fetch(:title)], style: styles.fetch(:title)

      config.fetch(:sections).each do |section|
        sheet.add_row [section[:name]], style: styles.fetch(:section)
        sheet.add_row config.fetch(:headers), style: styles.fetch(:header)
        section[:rows].each { |row| sheet.add_row yield(row) }
      end
      sheet.column_widths 36, 12, *Array.new(config.fetch(:headers).length - 2, 14)
    end
  end

  def add_viennoiserie_sheet(workbook, styles)
    workbook.add_worksheet(name: "Vienn Pick") do |sheet|
      sheet.add_row ["Bake List #{@bake_date.strftime('%A, %-m/%-d')}", nil, nil, "Vienn Pick"]
      sheet.add_row ["Viennoiserie"], style: styles.fetch(:section)
      sheet.add_row [
        "Item",
        "Total", nil,
        "Wholesale", nil,
        "Wholesale Check", nil,
        "Retail", nil,
        "Retail Check", nil
      ], style: styles.fetch(:header)
      sheet.add_row [
        nil,
        "Tray", "Piece",
        "Tray", "Piece",
        "Count", "Initial",
        "Tray", "Piece",
        "Count", "Initial"
      ], style: styles.fetch(:header)
      viennoiserie_rows.each { |row| sheet.add_row row }
      sheet.add_row []
      sheet.add_row ["Tray Counts"], style: styles.fetch(:title)
      sheet.add_row ["Item", "Qty per Tray"], style: styles.fetch(:header)
      @data.viennoiserie_pick_items.each do |row|
        next if row[:tray_count].blank?

        sheet.add_row [row[:product].name, row[:tray_count]]
      end
      sheet.column_widths 36, 10, 10, 10, 10, 14, 14, 10, 10, 14, 14
    end
  end

  def add_pull_list_sheet(workbook, styles)
    workbook.add_worksheet(name: "Pull-Prep List") do |sheet|
      sheet.add_row ["Pull-Prep List", @bake_date.iso8601], style: styles.fetch(:title)
      sheet.add_row []
      sheet.add_row %w[Product Qty Trays Checked], style: styles.fetch(:header)
      pull_list_rows.each { |row| sheet.add_row row }
      sheet.column_widths 36, 12, 18, 14
    end
  end

  def tray_parts(product, quantity)
    return [nil, quantity] unless product.pieces_per_tray.present? && product.pieces_per_tray.positive?

    quantity.divmod(product.pieces_per_tray)
  end

  def create_output_string(page)
    outstrio = StringIO.new
    page.use_shared_strings = true
    outstrio.write(page.to_stream.read)
    outstrio.string
  end
end
