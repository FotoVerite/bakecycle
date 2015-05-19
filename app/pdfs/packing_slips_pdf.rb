class PackingSlipsPdf < PdfReport
  def initialize(shipments, bakery, invoices = false)
    @shipments = shipments
    @bakery = bakery.decorate
    @invoices = invoices
    super(skip_page_creation: true)
  end

  def setup
    @shipments.each do |shipment|
      render_packing_slip(shipment)
      render_invoice(shipment)
    end
    timestamp
  end

  def render_packing_slip(shipment)
    start_new_page
    PackingSlipPdf.new(shipment, @bakery, self).setup
  end

  def render_invoice(shipment)
    return unless @invoices
    start_new_page
    InvoicePdf.new(shipment, @bakery, self).setup
  end
end
