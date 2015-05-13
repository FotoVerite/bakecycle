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
        date shipment.date_for_iif
        accnt 'Accounts Receivable'
        name shipment.client_name
        method_missing(:class)
        amount shipment.price_for_iif
        docnum shipment.invoice_number
        memo 'Wholesale'
        clear 'Y'
        toprint 'N'
        addr1 shipment.client_name
        addr2 shipment.client_delivery_address_street_1
        addr3 shipment.client_delivery_address_street_2
        addr4 shipment.client_state_zipcode
        addr5
        duedate shipment.due_date_for_iif
        terms shipment.terms
        paid 'N'
        paymeth
        shipdate shipment.date_for_iif
        rep
        ponum
        invtitle
        invmemo
      end

      shipment.shipment_items.each do |item|
        spl do
          row do
            splid item.id
            trnstype 'INVOICE'
            date shipment.date_for_iif
            accnt shipment.bakery_quickbooks_account
            name
            amount item.price_for_iif
            docnum
            memo item.product_name
            method_missing(:class, 'Wholesale')
            qnty item.product_quantity_for_iif
            price item.product_price_for_iif
            invitem item.product_product_type
            paymeth
            taxable 'N'
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
