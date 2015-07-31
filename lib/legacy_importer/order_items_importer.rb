module LegacyImporter
  class OrderItemsBuilder
    def self.items_for(bakery:, data:)
      new(bakery: bakery, data: data).make_order_items
    end

    DAY_OF_WEEK_MAP = {
      "mon" => :monday,
      "tue" => :tuesday,
      "wed" => :wednesday,
      "thu" => :thursday,
      "fri" => :friday,
      "sat" => :saturday,
      "sun" => :sunday
    }

    attr_reader :bakery, :data, :order_items

    def initialize(bakery:, data:, order_items: OrderItems)
      @data = data
      @order_items = order_items
      @bakery = bakery
    end

    def make_order_items
      legacy_order_items.each_with_object({}) { |legacy_item, item_index|
        product = lookup_product(legacy_item)
        next unless product

        item = item_index[product] ||= OrderItem.new(product: product)
        set_quantity_on_day(item, legacy_item)
      }.values
    end

    private

    def legacy_order_items
      order_items.find_for_order(data[:order_id])
    end

    def lookup_product(legacy_item)
      order_items.find_product(bakery, legacy_item[:orderitem_productid])
    end

    def set_quantity_on_day(item, legacy_item)
      name_of_day = DAY_OF_WEEK_MAP[legacy_item[:orderitem_day]]
      quantity = legacy_item[:orderitem_quantity]
      item.send(:"#{name_of_day}=", quantity)
    end
  end
end
