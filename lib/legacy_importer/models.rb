require 'uri'
require 'mysql2'

module LegacyImporter
  module DB
    def self.connection(connection_url: ENV['LEGACY_BAKECYCLE_DATABASE_URL'], connection: nil)
      @connection ||= connection || connect(connection_url)
    end

    def self.connect(connection_url)
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

    def self.query(sql)
      connection.query(sql, symbolize_keys: true, stream: true, cache_rows: false).to_a
    end
  end

  module Clients
    def self.all
      DB.query('SELECT * FROM bc_clients')
    end
  end

  module Ingredients
    def self.all
      DB.query('SELECT * FROM bc_ingredients')
    end
  end

  module Recipes
    def self.all
      DB.query('SELECT * FROM bc_recipes')
    end
  end

  class SkippedObject < OpenStruct
    def persisted?
      false
    end

    def valid?
      true
    end
  end
end
