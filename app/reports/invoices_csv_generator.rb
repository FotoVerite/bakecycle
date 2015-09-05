class InvoicesCsvGenerator
  attr_reader :bakery, :search
  include GlobalID::Identification

  def self.find(id)
    bakery_id, search_id = id.split("_", 2)
    new(Bakery.find(bakery_id), ShipmentSearchForm.find(search_id))
  end

  def initialize(bakery, search)
    @bakery = bakery
    @search = search
  end

  def id
    "#{bakery.id}_#{search.id}"
  end

  def filename
    "invoices.csv"
  end

  def generate
    invoices = bakery.shipments.search(search).includes(:shipment_items)
    InvoicesCsv.new(invoices).generate
  end
end
