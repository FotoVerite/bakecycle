class InvoicesCsv
  attr_reader :shipments

  def initialize(shipments)
    @shipments = shipments
  end

  def generate
    CSV.generate do |csv|
      csv << header
      @shipments.each do |shipment|
        csv << shipment_data_row(shipment)
      end
    end
  end

  private

  def header
    [
      "Invoice Number", "Client Name", "Client ID",
      "Invoice Date", "Invoice Subtotal", "Invoice fees", "Invoice total"
    ]
  end

  def shipment_data_row(shipment)
    [
      shipment.invoice_number, shipment.client_name, shipment.client_id,
      shipment.date, shipment.subtotal, shipment.delivery_fee, shipment.price
    ]
  end
end
