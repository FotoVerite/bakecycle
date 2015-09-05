class PackingSlipsGenerator
  include GlobalID::Identification

  def self.find(global_id)
    bakery_id, date_string, print_string = global_id.split("_")
    bakery = Bakery.find(bakery_id)
    date = Date.iso8601(date_string)
    print_invoices = print_string == "true"
    new(bakery, date, print_invoices)
  end

  def initialize(bakery, date, print_invoices)
    @bakery = bakery
    @date = date.to_date
    @print_invoices = print_invoices
  end

  def id
    "#{@bakery.id}_#{@date.iso8601}_#{@print_invoices}"
  end

  def filename
    formatted_date = @date.strftime("%Y-%m-%d")
    "packing_slips_#{formatted_date}.pdf"
  end

  def generate
    pdf.render
  end

  private

  def pdf
    PackingSlipsPdf.new(shipments, @bakery, @print_invoices)
  end

  def shipments
    Shipment.where(bakery: @bakery).search(date: @date).order_by_route_and_client.includes(:shipment_items)
  end
end
