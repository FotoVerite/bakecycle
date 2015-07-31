require "rails_helper"
require "legacy_importer"

describe LegacyImporter::PriceVariantImporter do
  let(:bakery) { create(:bakery) }
  let(:product) { create(:product, base_price: 0, legacy_id: 1, bakery: bakery) }
  let(:importer) { LegacyImporter::PriceVariantImporter.new(bakery, legacy_price_variant) }
  let(:legacy_price_variant) do
    {
      productprice_productid: product.legacy_id,
      productprice_quantity: 1,
      latest_price: 10.50
    }
  end

  describe "#import!" do
    it "imports product variant as product base price for existing product" do
      price_variant = importer.import!
      product.reload
      expect(product.base_price).to eq(price_variant.base_price)
    end
  end
end
