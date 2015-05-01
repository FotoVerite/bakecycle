class InvoicesIif < InvoiceIif
  attr_reader :shipments

  def initialize(shipments)
    @shipments = shipments
  end

  def generate
    invoices(@shipments).output
  end

  private

  def invoices(shipments)
    Riif::IIF.new do |riif|
      shipments.each do |shipment|
        shipment_data(riif, shipment)
      end
    end
  end
end
