module LegacyImporter
  class ProductImporter
    attr_reader :data, :bakery, :motherdough, :inclusion

    def initialize(bakery, legacy_product)
      @bakery = bakery
      @data = legacy_product
      @motherdough = Recipe.find_by(legacy_id: data[:product_recipeid])
      @inclusion = Recipe.find_by(legacy_id: data[:product_inclusionid])
    end

    FIELDS_MAP = %w(
      product_name          name
      product_shortname     sku
      product_description   description
      product_weight_g      weight
      product_extra         over_bake
      product_type          product_type
    ).map(&:to_sym).each_slice(2)

    PRODUCT_TYPE_MAP = {
      'Bread' => :bread,
      'Vienoisserie' =>  :vienoisserie,
      'Cookie' => :cookie,
      'Sandwich & Tartine' => :sandwich_and_tartine,
      'Quiche' => :quiche,
      'Tart & Dessert' => :tart_and_desert,
      'Pot Pie' => :pot_pie,
      'Other' => :other,
      'Dry Goods' => :dry_goods
    }

    def import!
      return SkippedProduct.new(data) if skip?
      Product.where(
        bakery: bakery,
        legacy_id: data[:product_id].to_s
      )
        .first_or_initialize
        .tap { |product| product.update(attributes) }
    end

    class SkippedProduct < SkippedObject
    end

    private

    def skip?
      data[:product_active] != 'Y'
    end

    def attr_map
      FIELDS_MAP.each_with_object({}) do |(legacy_field, field), data_hash|
        data_hash[field] = data[legacy_field] unless data[legacy_field] == ''
      end
    end

    def attributes
      attrs = attr_map
      attrs.merge(
        motherdough: motherdough,
        inclusion: inclusion,
        weight: adjusted_weight(attrs),
        product_type: PRODUCT_TYPE_MAP[attrs[:product_type]] || attrs[:product_type],
        unit: :g,
        base_price: 0
      )
    end

    def adjusted_weight(attrs)
      return attrs[:weight] unless inclusion && motherdough
      inclusion_percent = inclusion.total_bakers_percentage
      motherdough_percent = motherdough.total_bakers_percentage
      return attrs[:weight] if motherdough_percent == 0
      (attrs[:weight] / motherdough_percent * (motherdough_percent + inclusion_percent)).round(3)
    end
  end
end
