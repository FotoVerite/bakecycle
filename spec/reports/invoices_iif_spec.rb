# frozen_string_literal: true

require "rails_helper"

describe InvoicesIif do
  it "renders invoices from a collection of shipments" do
    create_list(:shipment, 2)
    iif = InvoicesIif.new(Shipment.all)
    expect(iif.generate).to_not be_nil
  end

  it "renders invoice discounts as itemized adjustments" do
    shipment = create(:shipment, discount_type: "fixed_amount", discount_value: 5)
    create(:shipment_item, shipment: shipment, bakery: shipment.bakery, product_quantity: 2, product_price: 10)

    iif = InvoicesIif.new(Shipment.where(id: shipment.id)).generate

    expect(iif).to include("Invoice Discount")
    expect(iif).to include("-5.0")
  end
end
