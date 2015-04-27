# rubocop:disable Metrics/MethodLength
require 'uri'
require 'mysql2'

module LegacyImporter
  module DB
    extend ActiveSupport::Benchmarkable

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
      benchmark "MYSQL Query: #{sql}" do
        connection.query(sql, symbolize_keys: true, stream: true, cache_rows: false)
      end
    end

    def self.logger
      Rails.logger
    end
  end

  class Clients
    def self.all
      DB.query('SELECT * FROM bc_clients')
    end
  end

  class Ingredients
    def self.all
      DB.query('SELECT * FROM bc_ingredients')
    end
  end

  class Recipes
    def self.all
      DB.query('SELECT * FROM bc_recipes')
    end
  end

  class RecipeItems
    def self.all
      DB.query('SELECT * FROM bc_recipeamts')
    end
  end

  class Products
    def self.all
      DB.query('SELECT * FROM bc_products')
    end
  end

  class PriceVarients
    def self.all
      DB.query('
        SELECT
        max(productprice_id) as productprice_id,
        productprice_productid,
        productprice_quantity,
        (
          SELECT  productprice_price
          FROM bc_productprices as t2
          WHERE
          t2.productprice_productid = t1.productprice_productid
          AND t2.productprice_quantity = t1.productprice_quantity
          ORDER BY productprice_validfrom desc
          LIMIT 1
          )
      as latest_price
      FROM bc_productprices t1
      GROUP BY productprice_productid, productprice_quantity
      ')
    end
  end

  class Routes
    def self.all
      DB.query('SELECT * FROM bc_routes')
    end
  end

  class Orders
    def self.all
      DB.query("
        SELECT *
        FROM bc_orders
        WHERE order_deleted = 'N'
      ")
    end

    def self.current_standing
      DB.query("
        SELECT * from bc_orders where order_id in (
          SELECT order_id
          FROM bc_orders
          LEFT JOIN bc_clients ON client_id = order_clientid
          LEFT JOIN bc_routes ON route_id = order_routeid
          WHERE order_deleted = 'N'
          AND order_enddate >= CURDATE()
          AND (
            (order_startdate >= CURDATE())
            OR (
              order_type = 'standing'
              AND order_startdate = (
                SELECT MAX(order_startdate) as order_startdate
                FROM bc_orders
                WHERE order_type = 'standing'
                AND order_deleted = 'N'
                AND order_startdate <= CURDATE()
                AND order_clientid = client_id
                AND order_routeid = route_id
              )
            )
          )
        )
      ")
    end
  end

  class OrderItems
    class << self
      extend Memoist
      def all
        DB.query('SELECT * FROM bc_orderitems')
      end

      def find_for_order(order_id)
        @_all_by_id ||= all.each_with_object({}) do |item, index|
          item_id = item[:orderitem_orderid]
          index[item_id] ||= []
          index[item_id].push(item)
        end
        @_all_by_id[order_id] || []
      end

      def find_route(bakery, legacy_route_id)
        Route.find_by(bakery: bakery, legacy_id: legacy_route_id.to_s)
      end

      def find_client(bakery, legacy_client_id)
        Client.find_by(bakery: bakery, legacy_id: legacy_client_id.to_s)
      end

      def find_product(bakery, legacy_product_id)
        Product.find_by(bakery: bakery, legacy_id: legacy_product_id.to_s)
      end

      def next_start_date(start_date, client_id, route_id, order_type)
        order_type = DB.connection.escape(order_type)
        DB.query("
          SELECT min(order_startdate) as next_start_date
          FROM bc_orders
          WHERE order_clientid=#{client_id}
            AND order_routeid=#{route_id}
            AND order_startdate > '#{start_date}'
            AND order_type='#{order_type}'
        ").map { |o| o[:next_start_date] }.first
      end
      memoize :next_start_date
    end
  end

  class SkippedObject < OpenStruct
    def persisted?
      false
    end

    def valid?
      true
    end

    def errors
      []
    end
  end

  class ObjectFinder
    def initialize(klass, where)
      @object = klass.where(where).first_or_initialize
    end

    def tap
      yield @object
      @object
    end

    def new?
      yield @object unless @object.persisted?
      self
    end

    def not_new?
      yield @object if @object.persisted?
      self
    end

    def save
      yield @object if block_given?
      @object.tap(&:save)
    end

    def update(attributes)
      tap { |object| object.update(attributes) }
    end
  end
end
