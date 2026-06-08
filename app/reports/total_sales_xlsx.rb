# frozen_string_literal: true

class TotalSalesXlsx
  include ActionView::Helpers::NumberHelper

  def initialize(bakery, start_date, end_date)
    @shipments = Shipment.where(bakery: bakery, date: start_date..end_date) || []
  end

  def generate
    CSV.generate do |csv|
      csv << header
      @shipments.each do |shipment|
        shipment_info = [shipment.invoice_number, shipment.date, shipment.updated_at.strftime("%Y-%m-%d %k:%M"),
                         shipment.client.name]
        shipment.shipment_items.each do |item|
          csv << invoice_row(shipment_info, item)
        end
      end
    end
  end

  private

  def header
    [
      "Invoice Number",
      "Date",
      "Updated At",
      "Client",
      "Category",
      "Item",
      "Qty",
      "SKU",
      "Net Sales"
    ]
  end

  def invoice_row(shipment_info, item)
    row = shipment_info.dup
    Rails.logger.error row
    row += [item.product_product_type, item.product_name, item.product_quantity, item.product_sku,
            number_to_currency(item.product_quantity * item.product_price)]
    Rails.logger.error row
    row
  end
end
