# frozen_string_literal: true

class TotalSalesXlsx
  include ActionView::Helpers::NumberHelper

  def initialize(bakery, start_date, end_date)
    @shipments = Shipment.where(bakery: bakery, date: start_date..end_date)
  end

  # includes + find_each rather than a bare `each`: every row needs the shipment's
  # client and its items, and `discount_amount` walks the items again for the
  # subtotal. Unbatched and unpreloaded that is two queries per shipment -- 38,487
  # queries for a six-month export, 160k for a two-year one. Preloading in batches
  # of 500 takes the same six-month export from 38,487 queries / 19.7s to 117 / 9.6s.
  #
  # find_each imposes primary-key ordering, which this query did not previously have
  # (no ORDER BY at all, so row order was whatever Postgres happened to return and
  # was never stable run-to-run). Row *order* in the output therefore changes; the
  # rows themselves and the totals are identical.
  def generate
    CSV.generate do |csv|
      csv << header
      @shipments.includes(:client, :shipment_items).find_each(batch_size: 500) do |shipment|
        shipment_info = [shipment.invoice_number, shipment.date, shipment.updated_at.strftime("%Y-%m-%d %k:%M"),
                         shipment.client.name]
        shipment.shipment_items.each do |item|
          csv << invoice_row(shipment_info, item)
        end
        csv << discount_row(shipment_info, shipment) if shipment.discount_amount.positive?
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

  def discount_row(shipment_info, shipment)
    shipment_info + [
      "Discount",
      "Invoice Discount",
      1,
      nil,
      number_to_currency(-shipment.discount_amount)
    ]
  end
end
