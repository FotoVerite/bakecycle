module LegacyImporter
  class ProductImporter
    attr_reader :data, :bakery, :motherdough, :inclusion

    def initialize(bakery, legacy_product)
      @bakery = bakery
      @data = legacy_product
      @motherdough = Recipe.find_by(legacy_id: data[:product_recipeid])
      @inclusion = Recipe.find_by(legacy_id: data[:product_inclusionid])
      @field_mapper = FieldMapper.new(FIELDS_MAP)
    end

    FIELDS_MAP = %w(
      product_name          name
      product_description   description
      product_weight_g      weight
      product_extra         over_bake
      product_type          product_type
    ).freeze
    # product_shortname     sku

    PRODUCT_TYPE_MAP = {
      "Bread" => :bread,
      "Vienoisserie" => :vienoisserie,
      "Cookie" => :cookie,
      "Sandwich & Tartine" => :sandwich_and_tartine,
      "Quiche" => :quiche,
      "Tart & Dessert" => :tart_and_desert,
      "Pot Pie" => :pot_pie,
      "Other" => :other,
      "Dry Goods" => :dry_goods
    }.freeze

    def import!
      return SkippedProduct.new(data) if skip?
      ObjectFinder.new(
        Product,
        bakery: bakery,
        legacy_id: data[:product_id].to_s
      )
        .new? { |product| product.base_price = 0 }
        .update_if_changed(attributes)
    end

    class SkippedProduct < SkippedObject
    end

    private

    def skip?
      data[:product_name].blank?
    end

    def attributes
      attrs = @field_mapper.translate(data)
      attrs.merge(
        motherdough: motherdough,
        inclusion: inclusion,
        weight: adjusted_weight(attrs),
        product_type: PRODUCT_TYPE_MAP[attrs[:product_type]] || attrs[:product_type],
        unit: :g,
        sku: nil
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
