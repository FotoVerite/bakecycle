class ProductionRunData
  attr_reader :bakery, :recipes, :production_run
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

  def run_items_by_product_name
    @_run_items_by_product_name ||= @run_items.order_by_product_type_and_name
  end

  def products
    run_items_by_product_name.map do |item|
      product = item.product.decorate
      {
        name: product.name,
        type: product.type,
        quantity: item.total_quantity
      }
    end
  end

  def processes_run_items
    run_items_by_product_name.each do |item|
      add_to_recipe_run_data(item.product, item.total_quantity)
    end
  end

  private

  def add_to_recipe_run_data(product, quantity)
    motherdough =  product.motherdough
    return unless motherdough
    recipe_data = recipes.find_or_create(motherdough, production_run.date)
    recipe_data.add_product(product, quantity)
    add_nested_recipes(recipe_data)
  end

  def add_nested_recipes(recipe_data)
    recipe_data.deeply_nested_recipe_info.each do |nested_info|
      nested_data = recipes.find_or_create(nested_info[:inclusionable], production_run.date)
      nested_data.add_parent_recipe(nested_info[:parent_recipe], nested_info[:weight])
    end
  end

  def max_product_lead_day
    (product_lead_days.max || 0).days
  end

  def product_lead_days
    @run_items.map { |items| items.product.total_lead_days }
  end
end
