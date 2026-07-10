# frozen_string_literal: true

# Shared Axlsx workbook plumbing. Every `*_xlsx.rb` report class independently
# reimplemented `create_output_string` -- 23 byte-identical copies before this
# module existed, including the same "Otherwise strings don't display in
# iWork Numbers" comment, copy-pasted rather than shared. That's serialization
# glue (Axlsx needs a String, not a stream, to hand back to ExporterJob), not
# per-report behavior, so it lives here once instead of copied per class.
#
# `row_style`/`zebra_bg` are opt-in for report classes that already render
# zebra-striped data rows with a bordered, cached style pair -- include this
# module and call them; don't add zebra striping to a report that doesn't
# already have it just because the helper is now shared.
module XlsxReport
  ZEBRA_BG = "F5F5F5"
  CELL_BORDER = { style: :thin, color: "000000" }.freeze

  def create_output_string(page)
    outstrio = StringIO.new
    page.use_shared_strings = true # Otherwise strings don't display in iWork Numbers
    outstrio.write(page.to_stream.read)
    outstrio.string
  end

  # Column A (the item name) stays left-aligned; every quantity column gets
  # centered. background nil/ZEBRA_BG picks the row tint. Cached since Axlsx
  # styles are cheap to reuse but not free to create -- every data row would
  # otherwise register two brand-new styles.
  def row_style(workbook_styles, column_count, background: nil)
    @row_style_cache ||= {}
    @row_style_cache[[column_count, background]] ||= begin
      label_style = workbook_styles.add_style(
        alignment: { horizontal: :left }, border: CELL_BORDER, **(background ? { bg_color: background } : {})
      )
      value_style = workbook_styles.add_style(
        alignment: { horizontal: :center }, border: CELL_BORDER, **(background ? { bg_color: background } : {})
      )
      [label_style] + Array.new(column_count - 1, value_style)
    end
  end

  def zebra_bg(index)
    index.odd? ? ZEBRA_BG : nil
  end
end
