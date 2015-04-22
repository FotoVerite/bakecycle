module LegacyImporter
  class OrderImporter
    attr_reader :data, :bakery, :order, :order_items

    def initialize(bakery, order_data, items_builder: OrderItemsBuilder)
      @bakery = bakery
      @data = order_data
      @field_mapper = FieldMapper.new(FIELDS_MAP)
      @order_items = items_builder.items_for(bakery: bakery, data: data)
    end

    FIELDS_MAP = %w(
      order_note      note
      order_type      order_type
    )

    def import!
      return SkippedOrder.new(attributes) if skip?
      ObjectFinder.new(
        Order,
        bakery: bakery,
        legacy_id: data[:order_id].to_s
      )
        .new? { |order| OrderFixer.new(order, data).set_dates }
        .update(attributes)
    end

    class SkippedOrder < SkippedObject
    end

    private

    def attributes
      @field_mapper.translate(data).merge(
        client: OrderItems.find_client(bakery, data[:order_clientid]),
        route: OrderItems.find_route(bakery, data[:order_routeid]),
        order_items: order_items
      )
    end

    def skip?
      client_missing? || order_deleted? || order_items.empty?
    end

    def client_missing?
      Client.find_by(bakery: bakery, legacy_id: data[:order_clientid].to_s).nil?
    end

    def order_deleted?
      data[:order_deleted] == 'Y'
    end
  end

  class OrderFixer
    attr_reader :order, :data
    def initialize(order, data)
      @order = order
      @data = data
    end

    def set_dates
      return if order.temporary?
      copy_dates
      set_end_date
    end

    private

    def set_end_date
      next_start_date = find_next_start_date
      order.end_date = (next_start_date - 1.day) if next_start_date
    end

    def copy_dates
      order.start_date = data[:order_startdate]
      if crazy_future_end_date?
        order.end_date = nil
      else
        order.end_date = data[:order_enddate]
      end
    end

    def crazy_future_end_date?
      data[:order_enddate] && data[:order_enddate] > Date.new(2029)
    end

    def find_next_start_date
      OrderItems.next_start_date(
        data[:order_startdate],
        data[:order_clientid],
        data[:order_routeid],
        data[:order_type]
      )
    end
  end
end
