module LegacyImporter
  class Importer
    include ActiveSupport::Benchmarkable
    attr_reader :bakery, :collection, :importer, :imported

    def initialize(bakery:, collection:, importer:)
      @bakery = bakery
      @collection = collection
      @importer = importer
    end

    def import!
      ActiveRecord::Base.connection.cache do
        benchmark "Imported #{bakery.name} with Importer #{importer}" do
          @imported = collection.map { |object| importer.new(bakery, object).import! }
        end
      end
    end

    private

    def logger
      Rails.logger
    end
  end

  class FieldMapper
    def initialize(field_map)
      @map_hash = convert_to_hash(field_map)
    end

    def translate(fields)
      fields.each_with_object({}) do |(key, value), object|
        new_key = map_hash[key] || next
        object[new_key] = value
      end
    end

    private

    attr_reader :map_hash

    def convert_to_hash(field_map)
      Hash[*field_map.map(&:to_sym)]
    end
  end
end
