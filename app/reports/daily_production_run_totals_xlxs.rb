class DailyProductionRunTotalsXlxs
  def initialize(bakery, date)
    @bakery = bakery
    @date = date
    @runs = ProductionRun.where(bakery: bakery, date: date)
  end

  def generate
    p = Axlsx::Package.new
    wb = p.workbook
    wb.add_worksheet(name: "Data Sheet") do |sheet|
      sheet.add_row ["Product Name",
                     "Total"]
      @runs.each do |run|
        run.run_items.each do |item|
          sheet.add_row [item.product.name, item.total_quantity]
        end
        sheet.add_row ["Total", run.run_items.sum(:total_quantity)]
      end
    end
    create_output_string(p)
  end

  def create_output_string(p)
    outstrio = StringIO.new
    p.use_shared_strings = true # Otherwise strings don't display in iWork Numbers
    outstrio.write(p.to_stream.read)
    outstrio.string
  end
end
