class InvoicesIifGenerator
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
    "#{bakery_file_name}_quickbooks#{date}.iif"
  end

  def generate
    InvoicesIif.new(invoices).generate
  end

  private

  def bakery_file_name
    bakery.decorate.parameterized_name
  end

  def invoices
    @_invoices ||= bakery.shipments.search(search)
  end

  def date
    date_from = invoices.minimum(:date)
    date_to = invoices.maximum(:date)
    "_#{date_from}_#{date_to}" if date_to && date_from
  end
end
