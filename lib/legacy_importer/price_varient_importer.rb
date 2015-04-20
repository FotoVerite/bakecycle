module LegacyImporter
  class PriceVarientImporter
    attr_reader :data, :bakery

    def initialize(bakery, legacy_price_varient)
      @bakery = bakery
      @data = legacy_price_varient
    end

    def import!
      product = Product.find_by(
        bakery: bakery,
        legacy_id: data[:productprice_productid].to_s
      )
      return SkippedPriceVarient.new(data) unless product
      product.tap { |p| p.update(base_price: data[:latest_price]) }
    end

    class SkippedPriceVarient < SkippedObject
    end
  end
end
