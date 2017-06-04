class InvoiceCsvGenerator
  attr_reader :bakery, :invoice
  include GlobalID::Identification

  def self.find(id)
    bakery_id, id = id.split("_", 2)
    new(Bakery.find(bakery_id), Bakery.find(bakery_id).shipments.find(id))
  end

  def initialize(bakery, invoice)
    @bakery = bakery
    @invoice = invoice
  end

  def id
    "#{bakery.id}_#{invoice.id}"
  end

  def filename
    "#{bakery_file_name}_invoice_#{@invoice.invoice_number}.csv"
  end

  def content_type
    "text/csv"
  end

  def generate
    InvoicesCsv.new([invoice]).generate
  end

  private

  def bakery_file_name
    bakery.decorate.parameterized_name
  end

end
