class DetailedInvoiceReportGenerator
  include GlobalID::Identification

  def self.find(global_id)
    bakery_id, date = global_id.split("_")
    bakery = Bakery.find(bakery_id)
    new(bakery, Date.iso8601(date))
  end

  def initialize(bakery, date)
    @bakery = bakery
    @date = date
  end

  def id
    "#{@bakery.id}_#{@date.iso8601}_detailedinvoicereport"
  end

  def filename
    "detailed_invoice_report_#{@date.iso8601}.xlsx"
  end

  def content_type
    "application/xlsx"
  end

  def generate
    DetailedInvoiceReportXlxs.new(@bakery, @date).generate
  end
end
