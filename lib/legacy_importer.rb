require 'legacy_importer/models'
require 'legacy_importer/importer'
require 'legacy_importer/reporter'
require 'legacy_importer/client_importer'
require 'legacy_importer/ingredient_importer'
require 'legacy_importer/recipe_importer'
require 'legacy_importer/recipe_item_importer'
require 'legacy_importer/product_importer'
require 'legacy_importer/price_varient_importer'
require 'legacy_importer/route_importer'
require 'legacy_importer/order_importer'
require 'legacy_importer/order_items_importer'

module LegacyImporter
  def self.bakery
    @_bakery ||= Bakery.find_by!(name: 'Bien Cuit')
  end

  def self.report(imported_objects)
    Reporter.new(imported_objects)
  end

  def self.import_clients
    Rails.logger.warn 'Importing Clients'
    Importer.new(
      bakery: bakery,
      collection: Clients.all,
      importer: ClientImporter
    )
      .import!
      .tap { |c| Rails.logger.warn "Imported #{c.count} clients" }
  end

  def self.import_ingredients
    Rails.logger.warn 'Importing Ingredients'
    Importer.new(
      bakery: bakery,
      collection: Ingredients.all,
      importer: IngredientImporter
    )
      .import!
      .tap { |c| Rails.logger.warn "Imported #{c.count} Ingredients" }
  end

  def self.import_recipes
    Rails.logger.warn 'Importing Recipes'
    Importer.new(
      bakery: bakery,
      collection: Recipes.all,
      importer: RecipeImporter
    )
      .import!
      .tap { |c| Rails.logger.warn "Imported #{c.count} Recipes" }
  end

  def self.import_recipe_items
    Rails.logger.warn 'Importing RecipeItems'
    Importer.new(
      bakery: bakery,
      collection: RecipeItems.all,
      importer: RecipeItemImporter
    )
      .import!
      .tap { |c| Rails.logger.warn "Imported #{c.count} RecipeItems" }
  end

  def self.import_products
    Rails.logger.warn 'Importing Products'
    Importer.new(
      bakery: bakery,
      collection: Products.all,
      importer: ProductImporter
    )
      .import!
      .tap { |c| Rails.logger.warn "Imported #{c.count} Products" }
  end

  def self.import_price_varients
    Rails.logger.warn 'Importing PriceVarients'
    Importer.new(
      bakery: bakery,
      collection: PriceVarients.all,
      importer: PriceVarientImporter
    )
      .import!
      .tap { |c| Rails.logger.warn "Imported #{c.count} PriceVarients" }
  end

  def self.import_routes
    Rails.logger.warn 'Importing Routes'
    Importer.new(
      bakery: bakery,
      collection: Routes.all,
      importer: RouteImporter
    )
      .import!
      .tap { |c| Rails.logger.warn "Imported #{c.count} Routes" }
  end

  def self.import_orders
    Rails.logger.warn 'Importing Orders'
    Importer.new(
      bakery: bakery,
      collection: Orders.all.to_a,
      importer: OrderImporter
    )
      .import!
      .tap { |c| Rails.logger.warn "Imported #{c.count} Orders" }
  end

  def self.import_all
    ActiveRecord::Base.connection.cache do
      [
        import_clients,
        import_ingredients,
        import_recipes,
        import_recipe_items,
        import_products,
        import_price_varients,
        import_routes,
        import_orders
      ].sum
    end
  end

  def self.make_shipments_and_production_runs
    ActiveRecord::Base.connection.cache do
      (bakery.orders.minimum(:start_date)..Time.zone.yesterday).each do |day|
        ShipmentService.new(bakery, day).run
        ProductionRunService.new(bakery, day).run
      end
    end
  end
end
