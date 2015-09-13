class InvoicesIif
  attr_reader :shipments

  def initialize(shipments)
    @shipments = shipments
  end

  def generate
    invoices(shipments).output
  end

  private

  def invoices(shipments)
    counter = LineCounter.new
    Riif::IIF.new do |riif|
      shipments.includes(:shipment_items).find_each do |shipment|
        invoice_data(riif, shipment.decorate, counter)
      end
    end
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def invoice_data(riif, shipment, row_counter)
    riif.trns do
      row do
        trnsid row_counter.next
        trnstype "INVOICE"
        date shipment.date_for_iif
        accnt "Accounts Receivable"
        name shipment.client_name
        method_missing(:class)
        amount shipment.price_for_iif
        docnum shipment.invoice_number
        memo "Wholesale"
        clear "Y"
        toprint "N"
        addr1 shipment.client_name
        addr2 shipment.client_delivery_address.full_array[0]
        addr3 shipment.client_delivery_address.full_array[1]
        addr4 shipment.client_delivery_address.full_array[2]
        addr5 shipment.client_delivery_address.full_array[3]
        duedate shipment.due_date_for_iif
        terms shipment.terms
        paid "N"
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
            splid row_counter.next
            trnstype "INVOICE"
            date shipment.date_for_iif
            accnt shipment.bakery_quickbooks_account
            name
            amount item.price_for_iif
            docnum
            memo item.product_name
            method_missing(:class, "Wholesale")
            qnty item.product_quantity_for_iif
            price item.product_price_for_iif
            invitem item.product_product_type
            paymeth
            taxable "N"
          end
        end
      end

      if shipment.delivery_fee_for_iif > 0
        spl do
          row do
            splid row_counter.next
            trnstype "INVOICE"
            date shipment.date_for_iif
            accnt shipment.bakery_quickbooks_account
            name
            amount "-#{shipment.delivery_fee_for_iif}"
            docnum
            memo "Delivery Fee"
            method_missing(:class, "Wholesale")
            qnty "-1"
            price shipment.delivery_fee_for_iif
            invitem "Delivery Fee"
            paymeth
            taxable "N"
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  class LineCounter
    def initialize
      @count = 0
    end

    def next
      @count += 1
    end
  end
end
