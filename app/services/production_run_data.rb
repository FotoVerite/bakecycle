class ProductionRunData
  attr_reader :bakery, :recipes, :production_run
  def initialize(production_run)
    @production_run = production_run
    @items = production_run.run_items
    @bakery = production_run.bakery
    @recipes = RecipeCollection.new
    processes_run_items
  end

  def id
    @production_run.id
  end

  def run_date
    production_run.date
  end

  def start_date
    run_date.strftime('%A %b. %e, %Y')
  end

  def end_date
    (run_date + max_product_lead_day).strftime('%A %b. %e, %Y')
  end

  def products
    run_items_by_product_name.group_by do |item|
      item.product.product_type
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
    recipe_data = recipes.find_or_create(motherdough, run_date)
    recipe_data.add_product(product, quantity)
    update_nested_recipes(recipe_data)
  end

  def update_nested_recipes(recipe_data)
    recipe_data.nested_recipes.each do |nested_info|
      nested_data = recipes.find_or_create(nested_info[:inclusionable], run_date)
      nested_data.update_parent_recipe(nested_info[:parent_recipe], nested_info[:weight])
      update_nested_recipes(nested_data)
    end
  end

  def max_product_lead_day
    (product_lead_days.max || 0).days
  end

  def product_lead_days
    @items.map { |items| items.product.total_lead_days }
  end

  def run_items_by_product_name
    @_run_items_by_product_name ||= @items.order_by_product_type_and_name
  end
end
