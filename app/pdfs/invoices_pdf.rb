class InvoicesPdf < BasePdfReport
  def initialize(shipments, bakery)
    @shipments = shipments
    @bakery = bakery.decorate
    super(skip_page_creation: true)
  end

  def setup
    @shipments.each do |shipment|
      start_new_page
      InvoicePage.new(shipment, @bakery, self).setup
    end
    timestamp
  end
end
