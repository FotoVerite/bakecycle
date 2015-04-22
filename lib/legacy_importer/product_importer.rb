module LegacyImporter
  class ProductImporter
    attr_reader :data, :bakery

    def initialize(bakery, legacy_product)
      @bakery = bakery
      @data = legacy_product
    end

    FIELDS_MAP = %w(
      product_name          name
      product_shortname     sku
      product_description   description
      product_weight_g      weight
      product_extra         over_bake
      product_type          product_type
    ).map(&:to_sym).each_slice(2)
    # product_recipeid      motherdough_id
    # product_inclusionid   inclusion_id

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
        .tap { |recipe| recipe.update(attributes) }
    end

    class SkippedProduct < SkippedObject
    end

    private

    def skip?
      data[:product_active] != 'Y'
    end

    def attributes
      attrs = attr_map
      attrs.merge(
        product_type: PRODUCT_TYPE_MAP[attrs[:product_type]] || attrs[:product_type],
        unit: :g,
        base_price: 0,
        motherdough: Recipe.find_by(legacy_id: data[:product_recipeid]),
        inclusion: Recipe.find_by(legacy_id: data[:product_inclusionid])
      )
    end

    def attr_map
      FIELDS_MAP.each_with_object({}) do |(legacy_field, field), data_hash|
        data_hash[field] = data[legacy_field] unless data[legacy_field] == ''
      end
    end
  end
end
