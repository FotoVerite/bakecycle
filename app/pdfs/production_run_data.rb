class ProductionRunData
  attr_reader :bakery, :recipes
  def initialize(production_run)
    @production_run = production_run
    @run_items = production_run.run_items
    @bakery = production_run.bakery
    @recipes = RecipeCollection.new
    processes_run_items
  end

  def id
    @production_run.id
  end

  def start_date
    @production_run.date.strftime('%A %b. %e, %Y')
  end

  def end_date
    (@production_run.date + max_product_lead_day).strftime('%A %b. %e, %Y')
  end

  def products
    @run_items.map do |item|
      { name: item.product.name, quantity: item.total_quantity }
    end
  end

  def processes_run_items
    @run_items.each do |item|
      product = item.product
      quantity = item.total_quantity
      add_to_recipe_run_data(product, quantity)
    end
  end

  def add_to_recipe_run_data(product, quantity)
    motherdough =  product.motherdough
    return unless motherdough
    recipe_run_data = recipes.find_or_create(motherdough)
    recipe_run_data.add(product, quantity)
    recipe_run_data
  end

  class RecipeCollection < Set
    def find_or_create(recipe)
      recipe_data = detect { |data| data.recipe == recipe } || RecipeRunData.new(recipe)
      add(recipe_data)
      recipe_data
    end
  end

  class RecipeRunData
    attr_reader :recipe, :products, :inclusions

    def initialize(recipe)
      @recipe = recipe
      @products = []
      @inclusions = Set.new
    end

    def add(product, quantity)
      @products.push([product, quantity])
      add_inclusion(product.inclusion) if product.inclusion
    end

    def add_inclusion(inclusion)
      @inclusions.add(inclusion)
    end
  end

  private

  def max_product_lead_day
    product_lead_days.max.days
  end

  def product_lead_days
    @run_items.map { |items| items.product.total_lead_days }
  end
end
