class InvoicesPdf < InvoicePdf
  def initialize(shipments)
    @shipments = shipments
    super(nil)
  end

  def setup
    shipment_invoices
    number_of_pages
  end

  def shipment_invoices
    @shipments.each do |shipment|
      @shipment = shipment
      invoice
      start_new_page unless shipment == @shipments.last
    end
  end
end
