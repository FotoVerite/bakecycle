class PackingSlipsPdf < BasePdfReport
  def initialize(shipments, bakery, print_invoices = false)
    @shipments = shipments
    @bakery = bakery.decorate
    @print_invoices = print_invoices
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
    PackingSlipPage.new(shipment, @bakery, self).render
  end

  def render_invoice(shipment)
    return unless @print_invoices
    InvoicePage.new(shipment, @bakery, self).render
  end
end
