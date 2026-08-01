# frozen_string_literal: true

class ClientTotalXlsx
  include XlsxReport

  def initialize(bakery, start_date, end_date)
    @bakery = bakery
    @start = start_date
    @end = end_date
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
    wb.add_worksheet(name: "Total") do |sheet|
      sheet.add_row headers
      add_rows(hash, sheet)
    end
    create_output_string(p)
  end

  def create_hash_clients
    hash = {}
    @clients.each do |client|
      invoices = client.shipments.where("shipments.date BETWEEN ? AND ?", @start, @end).non_sample
      invoice_total = invoices.to_a.sum(&:price)
      hash[client.name] = [client.name, invoices.count, invoice_total.to_s]
      @total += invoice_total
    end
    hash
  end

  def add_rows(hash, sheet)
    hash.each_value do |client_array|
      sheet.add_row client_array
    end
    sheet.add_row []
    sheet.add_row ["Total: #{@total}"]
  end
end
