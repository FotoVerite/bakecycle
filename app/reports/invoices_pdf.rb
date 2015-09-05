class InvoicesPdf < BasePdfReport
  def initialize(shipments, bakery)
    @shipments = shipments
    @bakery = bakery.decorate
    super(skip_page_creation: true)
  end

  def setup
    @shipments.each do |shipment|
      InvoicePage.new(shipment, @bakery, self).render
    end
    timestamp
  end
end
