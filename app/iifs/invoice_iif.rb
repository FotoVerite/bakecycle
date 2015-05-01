class InvoiceIif
  attr_reader :shipment

  def initialize(shipment)
    @shipment = shipment
  end

  def generate
    invoice(@shipment).output
  end

  private

  def invoice(shipment)
    Riif::IIF.new do |riif|
      shipment_data(riif, shipment)
    end
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def shipment_data(riif, shipment)
    riif.trns do
      row do
        trnsid shipment.id
        trnstype 'INVOICE'
        date shipment.date
        accnt 'Accounts Receivable'
        name shipment.client_name
        amount shipment.price
        docnum shipment.invoice_number
        addr1 shipment.client_name
        addr2 shipment.client_delivery_address_street_1
        addr3 shipment.client_delivery_address_street_2
        addr4 shipment.client_state_zipcode
        duedate shipment.payment_due_date
        terms shipment.client_billing_term
        shipdate shipment.date
      end

      shipment.shipment_items.each do |item|
        spl do
          row do
            splid item.id
            trnstype 'INVOICE'
            date shipment.date
            accnt shipment.bakery_quickbooks_account
            amount item.price
            memo item.product_name
            qnty item.product_quantity
            price item.product_price
            invitem item.product_product_type
            taxable 'N'
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
