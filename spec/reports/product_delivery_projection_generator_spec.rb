# frozen_string_literal: true

require "rails_helper"

describe ProductDeliveryProjectionGenerator do
  it "has a stable export id and filename" do
    bakery = create(:bakery)
    date = Date.new(2026, 6, 3)
    generator = described_class.new(bakery, date)

    expect(generator.id).to eq("#{bakery.id}_2026-06-03_delivery_product_projection")
    expect(generator.filename).to eq("DeliveryProductProjection-2026-06-03.xlsx")
  end

  it "finds a generator from its global id" do
    bakery = create(:bakery)

    generator = described_class.find("#{bakery.id}_2026-06-03_delivery_product_projection")

    expect(generator.filename).to eq("DeliveryProductProjection-2026-06-03.xlsx")
  end
end
