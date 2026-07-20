# frozen_string_literal: true

class YearTotalXlsx
  include XlsxReport

  def initialize(bakery, year)
    @bakery = bakery
    @year = year
    @clients = Client.where(bakery: bakery).order("name ASC")
    @total = 0
  end

  def generate
    hash = create_hash_clients
    headers = ["Client Name", "Invoice Numbers", "Total"]
    p = Axlsx::Package.new
    wb = p.workbook
    styles = wb.styles
    @header = styles.add_style sz: 16, b: true, alignment: { horizontal: :center }
    wb.add_worksheet(name: "#{@year} Total") do |sheet|
      sheet.add_row headers
      add_rows(hash, sheet)
    end
    create_output_string(p)
  end

  def create_hash_clients
    hash = {}
    @end_date = Time.zone.now.year == @year ? Time.zone.today : Date.parse("31-12-#{@year}")
    @clients.each do |client|
      invoices = client.shipments.where("shipments.date BETWEEN ? AND ?", Date.parse("1-1-#{@year}"), @end_date)
        .non_sample
      invoice_total = invoices.to_a.sum(&:price)
      hash[client.name] = [client.name, invoices.count, invoice_total.to_s]
      @total += invoice_total
    end
    hash
  end

  # rubocop:enable

  def add_rows(hash, sheet)
    # Set Product Type Row
    hash.each_value do |client_array|
      sheet.add_row client_array
    end
    sheet.add_row []
    sheet.add_row ["Total: #{@total}"]
  end

end
