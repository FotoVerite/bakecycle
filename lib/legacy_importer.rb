require 'legacy_importer/models'
require 'legacy_importer/importer'
require 'legacy_importer/reporter'
require 'legacy_importer/client_importer'
require 'legacy_importer/ingredient_importer'
require 'legacy_importer/recipe_importer'
require 'legacy_importer/recipe_item_importer'
require 'legacy_importer/product_importer'

module LegacyImporter
  def self.bakery
    @_bakery ||= Bakery.find_by!(name: 'Bien Cuit')
  end

  def self.report(imported_objects)
    Reporter.new(imported_objects)
  end

  def self.import_clients
    Importer.new(
      bakery: bakery,
      collection: Clients.all,
      importer: ClientImporter
    ).import!
  end

  def self.import_ingredients
    Importer.new(
      bakery: bakery,
      collection: Ingredients.all,
      importer: IngredientImporter
    ).import!
  end

  def self.import_recipes
    Importer.new(
      bakery: bakery,
      collection: Recipes.all,
      importer: RecipeImporter
    ).import!
  end

  def self.import_recipe_items
    Importer.new(
      bakery: bakery,
      collection: RecipeItems.all,
      importer: RecipeItemImporter
    ).import!
  end

  def self.import_products
    Importer.new(
      bakery: bakery,
      collection: Products.all,
      importer: ProductImporter
    ).import!
  end

  def self.import_all
    import_clients + import_ingredients + import_recipes + import_recipe_items + import_products
  end
end
