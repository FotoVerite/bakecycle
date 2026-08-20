# frozen_string_literal: true

# One workbook, reference-style sheets -- Retail Bread, Wholesale Bread,
# Pull Prep, and Vienn Pick -- matching the multi-worksheet precedent
# already established by SortedPackListXlsx. Blank check/count columns are
# literal nil cells for staff to fill in by hand.
class BakeListXlsx
  include XlsxReport

  delegate :retail_sections, :wholesale_sections, :pull_prep_sections, to: :@data

  ROULE_TOTAL_NAME = "ROULE TOTAL"

  # BOH trays Almond Croissant and Chocolate Almond Croissant by a different
  # count when proofing (Pull) than when they go in the oven (Bake), to save
  # proofing space -- so both bread sheets get a small extra section at the
  # bottom converting each item's own Total column into tray counts at both
  # sizes. Deliberately just these two named items, not every product with a
  # pieces_per_tray (confirmed with the client).
  TRAY_COUNT_ITEMS = ["Almond Croissant", "Chocolate Almond Croissant"].freeze
  PULL_TRAY_SIZE = 20
  BAKE_TRAY_SIZE = 15

  # Smith/Franklin are fixed retail-store columns, matched by client name
  # rather than derived from that
  # day's orders -- a store with no order that day still gets a 0, instead of
  # its whole column disappearing (confirmed with the client).
  #
  STORE_COLUMNS = { "Smith" => /smith/i, "Franklin" => /franklin/i }.freeze

  # Grand Central is a retail-style pickup point like Smith/Franklin -- Pull
  # Prep's Retail column is Smith + Franklin + Grand Central, and Wholesale is
  # whatever's left of the Total after that (confirmed against the client's
  # corrected 8/8 Bake List).
  PULL_PREP_STORE_COLUMNS = STORE_COLUMNS.merge("Grand Central" => /grand central/i).freeze
  OTHER_SHEET_HEADERS = (%w[Item Total] + PULL_PREP_STORE_COLUMNS.keys + ["Retail", "Blue Bottle", "Wholesale"]).freeze

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
    report_styles = {
      title: styles.add_style(b: true, sz: 16, alignment: { horizontal: :center }, border: CELL_BORDER),
      section: styles.add_style(bg_color: "B7B7B7", b: true, sz: 14, alignment: { horizontal: :center },
                                border: CELL_BORDER),
      header: styles.add_style(bg_color: "D9D9D9", b: true, alignment: { horizontal: :center },
                               border: CELL_BORDER)
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
    retail_sections.flat_map { |section| retail_section_rows(section) }
  end

  def wholesale_rows
    wholesale_sections.flat_map { |section| wholesale_section_rows(section) }
  end

  def other_rows
    pull_prep_sections.flat_map { |section| section[:rows].map { |row| other_row_cells(row) } }
  end

  def retail_tray_count_rows
    tray_count_rows(retail_totals_by_name)
  end

  def wholesale_tray_count_rows
    tray_count_rows(wholesale_totals_by_name)
  end

  def viennoiserie_rows
    @data.viennoiserie_pick_items.map do |row|
      # Synthetic fixed-tray rows (e.g. Pate Fermentee) carry their tray count
      # directly and have no retail/wholesale split to break down.
      next [row[:name], row[:fixed_trays], nil, nil, nil, nil, nil, nil, nil, nil, nil] if row[:fixed_trays]

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

  # Retail Bread, Wholesale Bread, and Pull Prep all carry a blank leading
  # column (unstyled, no border/fill) to the left of "Item" -- staff use it
  # to hand-check items off as they're pulled. Confirmed against the
  # client's own annotated 8/21 Bake List. Vienn Pick is intentionally
  # unchanged; it wasn't part of this request.
  def add_retail_sheet(workbook, styles)
    column_count = STORE_COLUMNS.length + 2
    workbook.add_worksheet(name: "Retail Bread") do |sheet|
      sheet.add_row [nil, "Bake List #{@bake_date.strftime('%A, %-m/%-d')}", nil, nil, "Retail Bread"]
      sheet.add_row [nil, "RETAIL"], style: [nil, styles.fetch(:title)]
      merge_row!(sheet, column_count, start_column: "B")

      retail_sections.each do |section|
        sheet.add_row [nil, section[:name]], style: [nil, styles.fetch(:section)]
        merge_row!(sheet, column_count, start_column: "B")
        sheet.add_row [nil, *(%w[Item Total] + STORE_COLUMNS.keys)],
                      style: [nil, *Array.new(column_count, styles.fetch(:header))]
        retail_section_rows(section).each_with_index do |cells, index|
          sheet.add_row [nil, *cells],
                        style: [checkbox_style, *row_style(@workbook_styles, column_count, background: zebra_bg(index))]
        end
      end
      add_tray_count_section(sheet, styles, column_count, retail_tray_count_rows)
      sheet.column_widths 5.33, 36, 12, *Array.new(column_count - 2, 18)
    end
  end

  def add_wholesale_sheet(workbook, styles)
    column_count = 4
    workbook.add_worksheet(name: "Wholesale Bread") do |sheet|
      sheet.add_row [nil, "Bake List #{@bake_date.strftime('%A, %-m/%-d')}", nil, nil, "Wholesale Bread"]
      sheet.add_row [nil, "WHOLESALE"], style: [nil, styles.fetch(:title)]
      merge_row!(sheet, column_count, start_column: "B")

      wholesale_sections.each do |section|
        sheet.add_row [nil, section[:name]], style: [nil, styles.fetch(:section)]
        merge_row!(sheet, column_count, start_column: "B")
        sheet.add_row [nil, "Item", "Total", "COUNT", "DIFFERENCE"],
                      style: [nil, *Array.new(column_count, styles.fetch(:header))]
        wholesale_section_rows(section).each_with_index do |cells, index|
          sheet.add_row [nil, *cells],
                        style: [checkbox_style, *row_style(@workbook_styles, column_count, background: zebra_bg(index))]
        end
      end
      add_tray_count_section(sheet, styles, column_count, wholesale_tray_count_rows)
      sheet.column_widths 6.5, 36, 12, 14
    end
  end

  def add_other_sheet(workbook, styles)
    column_count = OTHER_SHEET_HEADERS.length
    workbook.add_worksheet(name: "Pull Prep") do |sheet|
      sheet.add_row [nil, "Bake List #{@bake_date.strftime('%A, %-m/%-d')}", nil, nil, "Pull Prep"]

      pull_prep_sections.each do |section|
        sheet.add_row [nil, section[:name]], style: [nil, styles.fetch(:section)]
        merge_row!(sheet, column_count, start_column: "B")
        sheet.add_row [nil, *OTHER_SHEET_HEADERS], style: [nil, *Array.new(column_count, styles.fetch(:header))]
        section[:rows].each_with_index do |row, index|
          sheet.add_row [nil, *other_row_cells(row)],
                        style: [checkbox_style, *row_style(@workbook_styles, column_count, background: zebra_bg(index))]
        end
      end
      sheet.column_widths 6.5, 36, 12, *Array.new(column_count - 2, 14)
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
          sheet.add_row yield(row), style: row_style(@workbook_styles, column_count, background: zebra_bg(index))
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
      group_header_row = sheet.rows.size + 1
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
      merge_vienn_pick_headers!(sheet, group_header_row)
      viennoiserie_rows.each_with_index do |row, index|
        sheet.add_row row, style: row_style(@workbook_styles, 11, background: zebra_bg(index))
      end
      sheet.add_row []
      sheet.add_row ["Tray Counts"], style: styles.fetch(:title)
      merge_row!(sheet, 2)
      sheet.add_row ["Item", "Qty per Tray"], style: styles.fetch(:header)
      @data.viennoiserie_pick_items.select { |row| row[:pieces_per_tray].present? }.each_with_index do |row, index|
        sheet.add_row [row[:name], row[:pieces_per_tray]],
                      style: row_style(@workbook_styles, 2, background: zebra_bg(index))
      end
      sheet.column_widths 36, 14, 10, 10, 10, 14, 14, 10, 10, 14, 14
    end
  end

  def add_tray_count_section(sheet, styles, column_count, rows)
    sheet.add_row []
    sheet.add_row [nil, "TRAY COUNTS", "PULL", "BAKE"], style: [nil, *Array.new(3, styles.fetch(:header))]
    rows.each_with_index do |cells, index|
      sheet.add_row [nil, *cells],
                    style: [checkbox_style, *row_style(@workbook_styles, column_count, background: zebra_bg(index))]
    end
  end

  # A bordered-but-blank cell in the leading column of every line-item row
  # (not header/section/title rows) -- staff use it as a hand-check box.
  # Confirmed against the client's own annotated 8/21 Bake List: only real
  # item rows get the box, section/header/title banners stay borderless.
  def checkbox_style
    @checkbox_style ||= @workbook_styles.add_style(border: CELL_BORDER)
  end

  # Pull = proofing tray count (20/tray, to save proofing space), Bake = oven
  # tray count (15/tray) -- both rounded up, since a partial tray still needs
  # a whole tray (confirmed with the client). Items not present on the sheet
  # that day still get a row, at 0/0, matching the always-show-both-items
  # instruction.
  def tray_count_rows(totals_by_name)
    TRAY_COUNT_ITEMS.map do |name|
      total = totals_by_name.fetch(name, 0)
      [name, (total.to_f / PULL_TRAY_SIZE).ceil, (total.to_f / BAKE_TRAY_SIZE).ceil]
    end
  end

  def retail_totals_by_name
    retail_sections.flat_map { |section| section[:rows] }
      .each_with_object({}) { |row, memo| memo[row[:product].name] = row[:quantity] }
  end

  def wholesale_totals_by_name
    wholesale_sections.flat_map { |section| section[:rows] }
      .each_with_object({}) { |row, memo| memo[row[:product].name] = wholesale_total(row) }
  end

  def wholesale_section_rows(section)
    rows = section[:rows].map { |row| [row[:product].name, wholesale_total(row), nil, nil] }

    roule_rows = section[:rows].select { |row| roule_product?(row[:product]) }
    rows << [ROULE_TOTAL_NAME, roule_rows.sum { |row| wholesale_total(row) }, nil, nil] if roule_rows.size > 1
    rows
  end

  def retail_section_rows(section)
    rows = section[:rows].map { |row| retail_row_cells(row) }

    roule_rows = section[:rows].select { |row| roule_product?(row[:product]) }
    if roule_rows.size > 1
      rows << [ROULE_TOTAL_NAME, roule_rows.sum { |row| row[:quantity] }, *Array.new(STORE_COLUMNS.length)]
    end
    rows
  end

  # The Wholesale Bake sheet's Total = wholesale order + the whole day's
  # overbake for that product. Retail is baked to order (the Retail Bread
  # sheet is order-only), so all overbake is carried here. The overbake is the
  # authoritative Production Run / Daily Totals figure (see
  # BakeListData#wholesale_bake_total), so the three documents agree.
  def wholesale_total(row)
    @data.wholesale_bake_total(row[:product], row)
  end

  def retail_row_cells(row)
    [row[:product].name, row[:quantity], *store_quantities(row)]
  end

  # Retail = Smith + Franklin + Grand Central (all three retail-style pickup
  # points), Wholesale = whatever's left of the Total after that -- confirmed
  # against the client's corrected 8/8 Bake List (every row matched exactly).
  # Previously Retail only summed Smith + Franklin, so Grand Central's volume
  # silently fell into Wholesale instead.
  def other_row_cells(row)
    grand_central = pull_prep_store_quantity(row, PULL_PREP_STORE_COLUMNS.fetch("Grand Central"))
    retail = store_quantities(row).sum + grand_central
    blue_bottle = quantity_matching(row) { |client| client.name.match?(/blue bottle/i) }

    [row[:product].name, row[:quantity], *store_quantities(row), grand_central,
     retail, blue_bottle.zero? ? nil : blue_bottle, row[:quantity] - retail]
  end

  def store_quantities(row)
    STORE_COLUMNS.values.map { |pattern| store_quantity(row, pattern) }
  end

  def store_quantity(row, pattern)
    quantity_matching(row) { |client| client.name.start_with?("Bien Cuit") && client.name.match?(pattern) }
  end

  def pull_prep_store_quantity(row, pattern)
    store_quantity(row, pattern)
  end

  def quantity_matching(row, &matcher)
    row[:client_quantities].sum { |client, quantity| matcher.call(client) ? quantity : 0 }
  end

  def roule_product?(product)
    @data.roule_product?(product)
  end

  # Merges the row just added into a single banner cell spanning column_count
  # columns -- e.g. so a section header's grey fill spans the full row
  # instead of just column A. Must run immediately after the sheet.add_row
  # it applies to.
  def merge_row!(sheet, column_count, start_column: "A")
    row_number = sheet.rows.size
    start_index = ("A".."ZZ").to_a.index(start_column) + 1
    end_letter = column_letter(start_index + column_count - 1)
    sheet.merge_cells("#{start_column}#{row_number}:#{end_letter}#{row_number}")
  end

  def merge_vienn_pick_headers!(sheet, header_row)
    sheet.merge_cells("A#{header_row}:A#{header_row + 1}")
    %w[B:C D:E F:G H:I J:K].each do |columns|
      sheet.merge_cells("#{columns.split(':').first}#{header_row}:#{columns.split(':').last}#{header_row}")
    end
  end

  def column_letter(column_count)
    ("A".."ZZ").to_a[column_count - 1]
  end

  def tray_parts(pieces_per_tray, quantity)
    return [nil, quantity] unless pieces_per_tray.present? && pieces_per_tray.positive?

    quantity.divmod(pieces_per_tray)
  end
end
