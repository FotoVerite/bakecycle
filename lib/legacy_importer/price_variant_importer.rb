module LegacyImporter
  class PriceVariantImporter
    attr_reader :data, :bakery

    def initialize(bakery, legacy_price_variant)
      @bakery = bakery
      @data = legacy_price_variant
    end

    def import!
      product = Product.find_by(
        bakery: bakery,
        legacy_id: data[:productprice_productid].to_s
      )
      return SkippedPriceVariant.new(data) unless product
      product.tap do |p|
        p.base_price = data[:latest_price]
        p.save if p.changed?
      end
    end

    class SkippedPriceVariant < SkippedObject
    end
  end
end
