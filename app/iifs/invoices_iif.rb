class InvoicesIif < InvoiceIif
  attr_reader :shipments, :bakery

  def initialize(shipments, bakery)
    @shipments = shipments
    @bakery = bakery
  end

  def generate
    invoices(@shipments).output
  end

  def filename
    "#{bakery.name}-quickbooks_#{date_from}_#{date_to}.iif"
  end

  private

  def date_from
    shipments.max_by(&:date).date
  end

  def date_to
    shipments.min_by(&:date).date
  end

  def invoices(shipments)
    Riif::IIF.new do |riif|
      shipments.each do |shipment|
        shipment_data(riif, shipment)
      end
    end
  end
end
