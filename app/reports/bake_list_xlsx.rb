# frozen_string_literal: true

# One workbook, reference-style sheets -- Retail Bread, Wholesale Bread,
# Quiche & Dessert, and Vienn Pick -- matching the multi-worksheet precedent
# already established by SortedPackListXlsx. Blank check/count columns are
# literal nil cells for staff to fill in by hand. (The Quiche & Dessert sheet
# doubles as the pull/prep list, so there's no separate Pull/Prep sheet.)
class BakeListXlsx
  delegate :retail_sections, :wholesale_sections, :other_sections, to: :@data

  ROULE_TOTAL_NAME = "ROULE TOTAL"

  # Smith/Franklin are fixed store columns on both the Retail Bread and Quiche
  # & Dessert sheets, matched by client name rather than derived from that
  # day's orders -- a store with no order that day still gets a 0, instead of
  # its whole column disappearing (confirmed with the client).
  #
  # Grand Central ("Bien Cuit - Grand Central") is deliberately NOT a store
  # column: it can't take retail-bake items, so it has no place on the Retail
  # sheet, and on the Quiche & Dessert sheet its quantities must fall into the
  # Wholesale total with every other wholesale account rather than being split
  # out as a store (which previously subtracted them from Wholesale).
  STORE_COLUMNS = { "Smith" => /smith/i, "Franklin" => /franklin/i }.freeze

  # The Quiche & Dessert sheet always has these eight columns, matching the
  # hand-made bake list. Retail = the three stores summed; Wholesale =
  # everything else; Blue Bottle is a breakout within Wholesale.
  OTHER_SHEET_HEADERS = (%w[Item Total] + STORE_COLUMNS.keys + ["Retail", "Blue Bottle", "Wholesale"]).freeze

  ZEBRA_BG = "F5F5F5"

  def initialize(bakery, bake_date)
    @bakery = bakery
    @bake_date = bake_date.to_date
    @data = BakeListData.new(@bakery, @bake_date)
  end

  def generate
    package = Axlsx::Package.new
    workbook = package.workbook
    styles = workbook.styles
    @workbook_styles = styles
    @row_style_cache = {}
    report_styles = {
      title: styles.add_style(b: true, sz: 16, alignment: { horizontal: :center }),
      section: styles.add_style(bg_color: "B7B7B7", b: true, sz: 14, alignment: { horizontal: :center }),
      header: styles.add_style(bg_color: "D9D9D9", b: true, alignment: { horizontal: :center })
    }

    add_retail_sheet(workbook, report_styles)
    add_wholesale_sheet(workbook, report_styles)
    add_other_sheet(workbook, report_styles)
    add_viennoiserie_sheet(workbook, report_styles)

    create_output_string(package)
  end

  # Public row-builder methods, following ProductTotalsDateRangeXlsx's
  # testability convention: specs assert on these directly, never on parsed
  # xlsx bytes.
  def retail_rows
    retail_sections.flat_map { |section| section[:rows].map { |row| retail_row_cells(row) } }
  end

  def wholesale_rows
    wholesale_sections.flat_map { |section| wholesale_section_rows(section) }
  end

  def other_rows
    other_sections.flat_map { |section| section[:rows].map { |row| other_row_cells(row) } }
  end

  def viennoiserie_rows
    @data.viennoiserie_pick_items.map do |row|
      # Synthetic fixed-tray rows (e.g. Pate Fermentee) carry their tray count
      # directly and have no retail/wholesale split to break down.
      if row[:fixed_trays]
        next [row[:name], row[:fixed_trays], nil, nil, nil, nil, nil, nil, nil, nil, nil]
      end

      total_trays, total_pieces = tray_parts(row[:pieces_per_tray], row[:quantity])
      wholesale_trays, wholesale_pieces = tray_parts(row[:pieces_per_tray], row[:wholesale_quantity])
      retail_trays, retail_pieces = tray_parts(row[:pieces_per_tray], row[:retail_quantity])

      [
        row[:name],
        total_trays, total_pieces,
        wholesale_trays, wholesale_pieces, nil, nil,
        retail_trays, retail_pieces, nil, nil
      ]
    end
  end

  private

  def add_retail_sheet(workbook, styles)
    config = { title: "RETAIL", headers: %w[Item Total] + STORE_COLUMNS.keys, sections: retail_sections }
    add_sectioned_sheet(workbook, "Retail Bread", styles, config) { |row| retail_row_cells(row) }
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
        wholesale_section_rows(section).each_with_index do |cells, index|
          sheet.add_row cells, style: row_style(column_count, background: zebra_bg(index))
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
        section[:rows].each_with_index do |row, index|
          sheet.add_row other_row_cells(row), style: row_style(column_count, background: zebra_bg(index))
        end
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
        section[:rows].each_with_index do |row, index|
          sheet.add_row yield(row), style: row_style(column_count, background: zebra_bg(index))
        end
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
      viennoiserie_rows.each_with_index do |row, index|
        sheet.add_row row, style: row_style(11, background: zebra_bg(index))
      end
      sheet.add_row []
      sheet.add_row ["Tray Counts"], style: styles.fetch(:title)
      merge_row!(sheet, 2)
      sheet.add_row ["Item", "Qty per Tray"], style: styles.fetch(:header)
      @data.viennoiserie_pick_items.select { |row| row[:pieces_per_tray].present? }.each_with_index do |row, index|
        sheet.add_row [row[:name], row[:pieces_per_tray]], style: row_style(2, background: zebra_bg(index))
      end
      sheet.column_widths 36, 10, 10, 10, 10, 14, 14, 10, 10, 14, 14
    end
  end

  def wholesale_section_rows(section)
    rows = section[:rows].map { |row| [row[:product].name, wholesale_total(row), nil, nil] }

    roule_rows = section[:rows].select { |row| roule_product?(row[:product]) }
    if roule_rows.size > 1
      rows << [ROULE_TOTAL_NAME, roule_rows.sum { |row| wholesale_total(row) }, nil, nil]
    end
    rows
  end

  # The Wholesale Bake sheet's Total folds each product's overbake percentage in
  # on top of the ordered quantity -- staff bake orders + overbake, so the Total
  # column reflects the full amount actually baked (same orders + overbake math
  # as OrderItemQuantities#total_quantity). Retail bakes are baked to order and
  # keep an order-only total.
  def wholesale_total(row)
    quantity = row[:quantity]
    quantity + (quantity * row[:product].over_bake / 100).ceil
  end

  def retail_row_cells(row)
    [row[:product].name, row[:quantity], *store_quantities(row)]
  end

  def other_row_cells(row)
    retail = store_quantities(row).sum
    blue_bottle = quantity_matching(row) { |client| client.name.match?(/blue bottle/i) }

    [row[:product].name, row[:quantity], *store_quantities(row),
     retail, blue_bottle.zero? ? nil : blue_bottle, row[:quantity] - retail]
  end

  def store_quantities(row)
    STORE_COLUMNS.values.map { |pattern| store_quantity(row, pattern) }
  end

  def store_quantity(row, pattern)
    quantity_matching(row) { |client| client.name.start_with?("Bien Cuit") && client.name.match?(pattern) }
  end

  def quantity_matching(row, &matcher)
    row[:client_quantities].sum { |client, quantity| matcher.call(client) ? quantity : 0 }
  end

  # Column A (the item name) stays left-aligned; every quantity column gets
  # centered. background nil/ZEBRA_BG picks the row tint.
  # Cached since Axlsx styles are cheap to reuse but not free to create --
  # every data row would otherwise register two brand-new styles.
  def row_style(column_count, background: nil)
    @row_style_cache[[column_count, background]] ||= begin
      label_style = @workbook_styles.add_style(
        alignment: { horizontal: :left }, **(background ? { bg_color: background } : {})
      )
      value_style = @workbook_styles.add_style(
        alignment: { horizontal: :center }, **(background ? { bg_color: background } : {})
      )
      [label_style] + Array.new(column_count - 1, value_style)
    end
  end

  def zebra_bg(index)
    index.odd? ? ZEBRA_BG : nil
  end

  def roule_product?(product)
    @data.roule_product?(product)
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

  def tray_parts(pieces_per_tray, quantity)
    return [nil, quantity] unless pieces_per_tray.present? && pieces_per_tray.positive?

    quantity.divmod(pieces_per_tray)
  end

  def create_output_string(page)
    outstrio = StringIO.new
    page.use_shared_strings = true
    outstrio.write(page.to_stream.read)
    outstrio.string
  end
end
