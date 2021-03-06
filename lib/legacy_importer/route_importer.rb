module LegacyImporter
  class RouteImporter
    attr_reader :data, :bakery

    def initialize(bakery, legacy_route)
      @bakery = bakery
      @data = legacy_route
    end

    FIELDS_MAP = %w[
      route_time departure_time
      route_name name
      route_notes notes
    ].map(&:to_sym).each_slice(2)

    def import!
      ObjectFinder.new(
        Route,
        bakery: bakery,
        legacy_id: data[:route_id].to_s
      ).update_if_changed(attributes)
    end

    private

    def attributes
      attr_map.merge(
        active: route_active_status?
      )
    end

    def route_active_status?
      data[:route_active] == "Y"
    end

    def attr_map
      FIELDS_MAP.each_with_object({}) do |(legacy_field, field), data_hash|
        data_hash[field] = data[legacy_field] unless data[legacy_field] == ""
      end
    end
  end
end
