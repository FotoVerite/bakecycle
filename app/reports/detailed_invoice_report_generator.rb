class DetailedInvoiceReportGenerator
  include GlobalID::Identification

  def self.find(global_id)
    bakery_id, start_date, end_date = global_id.split("_")
    bakery = Bakery.find(bakery_id)
    new(bakery, Date.iso8601(start_date), Date.iso8601(end_date))
  end

  def initialize(bakery, start_date, end_date)
    @bakery = bakery
    @start_date = start_date
    @end_date = end_date
  end

  def id
    "#{@bakery.id}_#{@start_date.iso8601}_#{@end_date.iso8601}_detailedinvoicereport"
  end

  def filename
    "detailed_invoice_report_#{@start_date.iso8601}_#{@end_date.iso8601}.xlsx"
  end

  def content_type
    "application/xlsx"
  end

  def generate
    DetailedInvoiceReportXlxs.new(@bakery, @start_date, @end_date).generate
  end
end
