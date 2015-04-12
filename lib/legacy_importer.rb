require 'mysql2'
require 'uri'

require 'legacy_importer/legacy_client_importer'
require 'legacy_importer/legacy_ingredient_importer'

class LegacyImporter
  attr_reader :connection, :bakery

  def initialize(bakery:, connection_url: ENV['LEGACY_BAKECYCLE_DATABASE_URL'], connection: nil)
    @bakery = bakery
    @connection = connection || connect(connection_url)
  end

  def connect(connection_url)
    info = URI.parse(connection_url)
    database = info.path.gsub(%r{^/}, '')
    Mysql2::Client.new(
      host: info.host,
      username: info.user,
      password: info.password,
      database: database,
      reconnect: true
    )
  end

  def clients
    LegacyClientImporter.new(bakery: bakery, connection: connection)
  end

  def ingredients
    LegacyIngredientImporter.new(bakery: bakery, connection: connection)
  end
end
