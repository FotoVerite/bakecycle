class DemoExporter
  DEMO_DATA_YAML = 'config/demo_data.yml'

  attr_reader :bakery

  def initialize(bakery)
    @bakery = bakery
  end

  def run
    ActiveRecord::Base.transaction do
      write
    end
  end

  def write
    File.write(Rails.root.join(DEMO_DATA_YAML), export.to_yaml)
  end

  def export
    @export ||= reindexed_data
  end

  private

  attr_reader :data

  def reindexed_data
    fetcher = Fetcher.new(bakery)
    Reindexer.new(fetcher.fetch).reindex
  end

  class Fetcher
    attr_reader :bakery
    def initialize(bakery)
      @bakery = bakery
    end

    def fetch
      {
        clients: clients,
        routes: routes,
        ingredients: ingredients,
        recipes: recipes,
        recipe_items: recipe_items,
        products: products,
        orders: orders,
        order_items: order_items,
        price_variants: price_variants
      }
    end

    private

    def ingredients
      pluck_fields(bakery.ingredients)
    end

    def clients
      pluck_fields(bakery.clients)
    end

    def routes
      pluck_fields(bakery.routes)
    end

    def products
      pluck_fields(bakery.products)
    end

    def recipes
      pluck_fields(bakery.recipes)
    end

    def recipe_items
      items = RecipeItem.joins(:recipe).where(recipes: { bakery_id: bakery.id })
      pluck_fields(items)
    end

    def orders
      pluck_fields(bakery.orders)
    end

    def order_items
      pluck_fields(bakery.order_items)
    end

    def price_variants
      prices = PriceVariant.joins(:product).where(products: { bakery_id: bakery.id })
      pluck_fields(prices)
    end

    def pluck_fields(model, *skip_fields)
      skip = [:id, :total_lead_days, :bakery_id, :updated_at, :created_at, :legacy_id, *skip_fields]
      fields = model.column_names.map(&:to_sym) - skip
      model.order(:id).all.each_with_object({}) { |i, o| o[i.id] =  i.slice(*fields) }
    end
  end

  class Reindexer
    attr_reader :data
    def initialize(data)
      @data = data
    end

    def reindex
      reindex_routes
      reindex_orders
      reindex_table(:recipe_items)
      reindex_table(:order_items)
      reindex_table(:price_variants)
      reindex_clients
      reindex_recipes
      reindex_ingredients
      reindex_products
      data
    end

    private

    def reindex_routes
      id_map = reindex_table(:routes)
      reindex_fk(id_map, :orders, :route_id)
    end

    def reindex_orders
      id_map = reindex_table(:orders)
      reindex_fk(id_map, :order_items, :order_id)
    end

    def reindex_clients
      id_map = reindex_table(:clients)
      reindex_fk(id_map, :orders, :client_id)
      reindex_fk(id_map, :price_variants, :client_id)
    end

    def reindex_products
      id_map = reindex_table(:products)
      reindex_fk(id_map, :order_items, :product_id)
      reindex_fk(id_map, :price_variants, :product_id)
    end

    def reindex_recipes
      id_map = reindex_table(:recipes)
      reindex_fk(id_map, :recipe_items, :recipe_id)
      reindex_fk(id_map, :products, :motherdough_id)
      reindex_fk(id_map, :products, :inclusion_id)
      reindex_inclusionables('Recipe', id_map)
    end

    def reindex_ingredients
      id_map = reindex_table(:ingredients)
      reindex_inclusionables('Ingredient', id_map)
    end

    def reindex_inclusionables(type, id_map)
      data[:recipe_items].values.each do |attr_hash|
        next unless attr_hash[:inclusionable_type] == type
        attr_hash[:inclusionable_id] = id_map[attr_hash[:inclusionable_id]]
      end
    end

    def reindex_fk(id_map, table, fk)
      data[table].values.each do |attr_hash|
        attr_hash[fk] = id_map[attr_hash[fk]]
      end
    end

    def reindex_table(table)
      new_index = {}
      counter = 0
      id_map = {}
      data[table].each do |old_id, attr_hash|
        counter += 1
        id_map[old_id] = counter
        new_index[counter] = attr_hash
      end
      data[table] = new_index
      id_map
    end
  end
end
