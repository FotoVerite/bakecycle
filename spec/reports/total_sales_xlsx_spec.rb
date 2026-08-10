# frozen_string_literal: true

require "rails_helper"

describe TotalSalesXlsx do
  it "adds invoice discounts as negative sales rows" do
    bakery = create(:bakery)
    shipment = create(
      :shipment,
      bakery: bakery,
      discount_type: "fixed_amount",
      discount_value: 5,
      date: Date.new(2026, 6, 2)
    )
    create(:shipment_item, bakery: bakery, shipment: shipment, product_quantity: 2, product_price: 10)

    csv = TotalSalesXlsx.new(bakery, shipment.date, shipment.date).generate
    rows = CSV.parse(csv)

    expect(rows.map { |row| row[5] }).to include("Invoice Discount")
    discount_row = rows.detect { |row| row[5] == "Invoice Discount" }
    expect(discount_row[8]).to eq("-$5.00")
  end

  it "includes sample-order shipments, like any other zero-charge invoice" do
    bakery = create(:bakery)
    client = create(:client, bakery: bakery, name: "Triplet")
    order = create(:order, bakery: bakery, client: client, order_type: "sample")
    shipment = create(:shipment, bakery: bakery, client: client, order: order, date: Date.new(2026, 8, 11))
    create(:shipment_item, bakery: bakery, shipment: shipment, product_quantity: 2, product_price: 0)

    csv = TotalSalesXlsx.new(bakery, shipment.date, shipment.date).generate
    rows = CSV.parse(csv)

    expect(rows.map { |row| row[3] }).to include("Triplet")
  end
end
