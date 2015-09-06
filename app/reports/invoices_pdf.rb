class InvoicesPdf < BasePdfReport
  attr_reader :bakery, :shipments

  def initialize(bakery, shipments)
    @bakery = bakery.decorate
    @shipments = shipments
    super(skip_page_creation: true)
  end

  def setup
    shipments.includes(:shipment_items).find_each do |shipment|
      InvoicePage.new(shipment, bakery, self).render
    end
    timestamp
  end
end
