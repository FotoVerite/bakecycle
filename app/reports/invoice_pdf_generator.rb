class InvoicePdfGenerator
  attr_reader :bakery, :shipment
  include GlobalID::Identification

  def self.find(id)
    bakery_id, shipment_id = id.split("_", 2)
    new(Bakery.find(bakery_id), Shipment.find(shipment_id))
  end

  def initialize(bakery, shipment)
    @bakery = bakery
    @shipment = shipment
  end

  def id
    "#{bakery.id}_#{shipment.id}"
  end

  def filename
    "#{bakery_file_name}_invoice_#{shipment.invoice_number}.pdf"
  end

  def generate
    InvoicesPdf.new(bakery, bakery.shipments.where(id: shipment.id)).render
  end

  private

  def bakery_file_name
    bakery.decorate.parameterized_name
  end
end
