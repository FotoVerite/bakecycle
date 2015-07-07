# rubocop:disable Rails/Output
# rubocop:disable Metrics/ModuleLength

require 'legacy_importer/models'
require 'legacy_importer/importer'
require 'legacy_importer/reporter'
require 'legacy_importer/client_importer'
require 'legacy_importer/ingredient_importer'
require 'legacy_importer/recipe_importer'
require 'legacy_importer/recipe_item_importer'
require 'legacy_importer/product_importer'
require 'legacy_importer/price_variant_importer'
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
    puts 'Importing Clients'
    Importer.new(
      bakery: bakery,
      collection: Clients.all,
      importer: ClientImporter
    )
      .import!
      .tap { |c| puts "Imported #{c.count} clients" }
  end

  def self.import_ingredients
    puts 'Importing Ingredients'
    Importer.new(
      bakery: bakery,
      collection: Ingredients.all,
      importer: IngredientImporter
    )
      .import!
      .tap { |c| puts "Imported #{c.count} Ingredients" }
  end

  def self.import_recipes
    puts 'Importing Recipes'
    Importer.new(
      bakery: bakery,
      collection: Recipes.all,
      importer: RecipeImporter
    )
      .import!
      .tap { |c| puts "Imported #{c.count} Recipes" }
  end

  def self.import_recipe_items
    puts 'Importing RecipeItems'
    Importer.new(
      bakery: bakery,
      collection: RecipeItems.all,
      importer: RecipeItemImporter
    )
      .import!
      .tap { |c| puts "Imported #{c.count} RecipeItems" }
  end

  def self.import_products
    puts 'Importing Products'
    Importer.new(
      bakery: bakery,
      collection: Products.all,
      importer: ProductImporter
    )
      .import!
      .tap { |c| puts "Imported #{c.count} Products" }
  end

  def self.import_price_variants
    puts 'Importing PriceVariants'
    Importer.new(
      bakery: bakery,
      collection: PriceVariants.all,
      importer: PriceVariantImporter
    )
      .import!
      .tap { |c| puts "Imported #{c.count} PriceVariants" }
  end

  def self.import_routes
    puts 'Importing Routes'
    Importer.new(
      bakery: bakery,
      collection: Routes.all,
      importer: RouteImporter
    )
      .import!
      .tap { |c| puts "Imported #{c.count} Routes" }
  end

  def self.import_orders
    puts 'Importing Orders'
    Importer.new(
      bakery: bakery,
      collection: Orders.all.to_a,
      importer: OrderImporter
    )
      .import!
      .tap { |c| puts "Imported #{c.count} Orders" }
  end

  def self.import_all
    [
      import_clients,
      import_ingredients,
      import_recipes,
      import_recipe_items,
      import_products,
      import_price_variants,
      import_routes,
      import_orders
    ].sum
  end

  def self.back_fill_data
    ActiveRecord::Base.connection.cache do
      make_shipments
    end
    ActiveRecord::Base.connection.cache do
      make_production_runs
    end
    reset_kickoff_time
  end

  def self.make_shipments
    (bakery.orders.minimum(:start_date)..Time.zone.yesterday).each do |date|
      ShipmentService.new(bakery, date).run
    end
  end

  def self.make_production_runs
    (bakery.orders.minimum(:start_date)..Time.zone.yesterday).each do |date|
      ProductionRunService.new(bakery, date).run
    end
  end

  def self.delete_all
    [
      ProductionRun,
      Shipment,
      Order,
      Client,
      Route,
      Product,
      Recipe,
      Ingredient
    ].each do |klass|
      klass.where(bakery: bakery).delete_all
    end
  end

  def self.reset_kickoff_time
    bakery.update!(last_kickoff: nil)
  end
end
