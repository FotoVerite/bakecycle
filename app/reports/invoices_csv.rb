class InvoicesCsv
  attr_reader :invoices

  def initialize(invoices)
    @invoices = invoices
  end

  def generate
    CSV.generate do |csv|
      csv << header
      @invoices.each do |invoice|
        csv << invoice_row(invoice)
      end
    end
  end

  private

  def header
    [
      "Invoice Number",
      "Client Name",
      "Client ID",
      "Invoice Date",
      "Invoice Subtotal",
      "Invoice fees",
      "Invoice total"
    ]
  end

  def invoice_row(invoice)
    [
      invoice.invoice_number,
      invoice.client_name,
      invoice.client_id,
      invoice.date,
      invoice.subtotal,
      invoice.delivery_fee,
      invoice.price
    ]
  end
end
