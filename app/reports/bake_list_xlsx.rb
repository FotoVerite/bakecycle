# frozen_string_literal: true

# One workbook, reference-style sheets -- Retail Bread, Wholesale Bread,
# Vienn Pick, and Pull/Prep List -- matching the multi-worksheet precedent
# already established by SortedPackListXlsx. Blank check/count columns are
# literal nil cells for staff to fill in by hand.
class BakeListXlsx
  delegate :retail_sections, :wholesale_sections, :retail_clients, :other_sections, to: :@data

  # Wholesale Bread rows for these products get bolded/highlighted, flagging
  # that the tray/piece breakdown for this item lives on the Vienn Pick
  # sheet instead (confirmed with the client: highlight = tray-tracked).
  ROULE_TOTAL_NAME = "ROULE TOTAL"

  # Client names like "Bien Cuit - Franklin Ave Retail Bake" are too long to
  # use as a column header without either wrapping or overflowing into the
  # next column, so header cells get truncated to this length.
  CLIENT_HEADER_LENGTH = 18

  # The Quiche & Dessert sheet always has these six columns (plus Item),
  # matching the hand-made bake list. The three store columns match Bien Cuit
  # clients by name -- store orders arrive on either bake lead, so they can't
  # be derived from lead days. Retail = the three stores summed; Wholesale =
  # everything else; Blue Bottle is a breakout within Wholesale.
  OTHER_SHEET_HEADERS = ["Item", "Total", "Smith", "Franklin", "GCM", "Retail", "Blue Bottle", "Wholesale"].freeze
  OTHER_SHEET_STORES = { "Smith" => /smith/i, "Franklin" => /franklin/i, "GCM" => /grand central/i }.freeze

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
      header: styles.add_style(bg_color: "D9D9D9", b: true, alignment: { horizontal: :center }),
      highlight: styles.add_style(bg_color: "FFF2CC", b: true)
    }

    add_retail_sheet(workbook, report_styles)
    add_wholesale_sheet(workbook, report_styles)
    add_other_sheet(workbook, report_styles)
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
    wholesale_sections.flat_map { |section| wholesale_section_rows(section).map { |row| row[:cells] } }
  end

  def other_rows
    other_sections.flat_map { |section| section[:rows].map { |row| other_row_cells(row) } }
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
    config = {
      title: "RETAIL",
      headers: %w[Item Total] + retail_clients.map { |client| client_header(client) },
      sections: retail_sections
    }
    add_sectioned_sheet(workbook, "Retail Bread", styles, config) do |row|
      [row[:product].name, row[:quantity]] + retail_clients.map { |client| row[:client_quantities][client].to_i }
    end
  end

  def add_wholesale_sheet(workbook, styles)
    column_count = 4
    workbook.add_worksheet(name: "Wholesale Bread") do |sheet|
      sheet.add_row ["Bake List #{@bake_date.strftime('%A, %-m/%-d')}", nil, nil, "Wholesale Bread"]
      sheet.add_row ["WHOLESALE"], style: styles.fetch(:title)
      merge_row!(sheet, column_count)

      wholesale_sections.each do |section|
        sheet.add_row [section[:name]], style: styles.fetch(:section)
        merge_row!(sheet, column_count)
        sheet.add_row %w[Item Total MISSING EXTRA], style: styles.fetch(:header)
        wholesale_section_rows(section).each do |row|
          sheet.add_row row[:cells], style: row[:highlighted] ? styles.fetch(:highlight) : nil
        end
      end
      sheet.column_widths 36, 12, 14, 14
    end
  end

  def add_other_sheet(workbook, styles)
    column_count = OTHER_SHEET_HEADERS.length
    workbook.add_worksheet(name: "Quiche & Dessert") do |sheet|
      sheet.add_row ["Bake List #{@bake_date.strftime('%A, %-m/%-d')}", nil, nil, "Quiche & Dessert"]

      other_sections.each do |section|
        sheet.add_row [section[:name]], style: styles.fetch(:section)
        merge_row!(sheet, column_count)
        sheet.add_row OTHER_SHEET_HEADERS, style: styles.fetch(:header)
        section[:rows].each { |row| sheet.add_row other_row_cells(row) }
      end
      sheet.column_widths 36, 12, *Array.new(column_count - 2, 14)
    end
  end

  def add_sectioned_sheet(workbook, sheet_name, styles, config)
    column_count = config.fetch(:headers).length
    workbook.add_worksheet(name: sheet_name) do |sheet|
      sheet.add_row ["Bake List #{@bake_date.strftime('%A, %-m/%-d')}", nil, nil, sheet_name]
      sheet.add_row [config.fetch(:title)], style: styles.fetch(:title)
      merge_row!(sheet, column_count)

      config.fetch(:sections).each do |section|
        sheet.add_row [section[:name]], style: styles.fetch(:section)
        merge_row!(sheet, column_count)
        sheet.add_row config.fetch(:headers), style: styles.fetch(:header)
        section[:rows].each { |row| sheet.add_row yield(row) }
      end
      sheet.column_widths 36, 12, *Array.new(column_count - 2, 18)
    end
  end

  def add_viennoiserie_sheet(workbook, styles)
    workbook.add_worksheet(name: "Vienn Pick") do |sheet|
      sheet.add_row ["Bake List #{@bake_date.strftime('%A, %-m/%-d')}", nil, nil, "Vienn Pick"]
      sheet.add_row ["Viennoiserie"], style: styles.fetch(:section)
      merge_row!(sheet, 11)
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
      merge_row!(sheet, 2)
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
      merge_row!(sheet, 4)
      sheet.add_row []
      sheet.add_row %w[Product Qty Trays Checked], style: styles.fetch(:header)
      pull_list_rows.each { |row| sheet.add_row row }
      sheet.column_widths 36, 12, 18, 14
    end
  end

  def wholesale_section_rows(section)
    rows = section[:rows].map do |row|
      { cells: [row[:product].name, row[:quantity], nil, nil], highlighted: tray_tracked?(row[:product]) }
    end

    roule_rows = section[:rows].select { |row| roule_product?(row[:product]) }
    if roule_rows.size > 1
      rows << { cells: [ROULE_TOTAL_NAME, roule_rows.sum { |row| row[:quantity] }, nil, nil], highlighted: true }
    end
    rows
  end

  def other_row_cells(row)
    store_quantities = OTHER_SHEET_STORES.values.map { |pattern| store_quantity(row, pattern) }
    retail = store_quantities.sum
    blue_bottle = quantity_matching(row) { |client| client.name.match?(/blue bottle/i) }

    [row[:product].name, row[:quantity], *store_quantities,
     retail, blue_bottle.zero? ? nil : blue_bottle, row[:quantity] - retail]
  end

  def store_quantity(row, pattern)
    quantity_matching(row) { |client| client.name.start_with?("Bien Cuit") && client.name.match?(pattern) }
  end

  def quantity_matching(row, &matcher)
    row[:client_quantities].sum { |client, quantity| matcher.call(client) ? quantity : 0 }
  end

  def client_header(client)
    client.name.truncate(CLIENT_HEADER_LENGTH)
  end

  def tray_tracked?(product)
    product.pieces_per_tray.present? && product.pieces_per_tray.positive?
  end

  def roule_product?(product)
    product.name.match?(/\Aroule\b/i)
  end

  # Merges the row just added into a single banner cell spanning column_count
  # columns -- e.g. so a section header's grey fill spans the full row
  # instead of just column A. Must run immediately after the sheet.add_row
  # it applies to.
  def merge_row!(sheet, column_count)
    row_number = sheet.rows.size
    sheet.merge_cells("A#{row_number}:#{column_letter(column_count)}#{row_number}")
  end

  def column_letter(column_count)
    ("A".."ZZ").to_a[column_count - 1]
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
