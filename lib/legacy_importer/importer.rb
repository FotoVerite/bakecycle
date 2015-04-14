module LegacyImporter
  class Importer
    attr_reader :bakery, :collection, :importer, :imported

    def initialize(bakery:, collection:, importer:)
      @bakery = bakery
      @collection = collection
      @importer = importer
    end

    def import!
      Skylight.instrument title: importer.to_s do
        @imported = collection.map { |object| importer.new(bakery, object).import! }
      end
    end
  end
end
