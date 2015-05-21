class ProjectionRunData < ProductionRunData
  attr_reader :bakery, :recipes, :projection_run
  def initialize(projection_run)
    @projection_run = projection_run
    @items = projection_run.order_items
    @bakery = projection_run.bakery
    @recipes = RecipeCollection.new
    processes_run_items
  end

  def run_date
    projection_run.start_date
  end

  def products
    projection_run.products_info.map do |item|
      product = item.product.decorate
      {
        name: product.name,
        type: product.type,
        quantity: item.total_quantity
      }
    end
  end

  def processes_run_items
    projection_run.products_info.each do |item|
      add_to_recipe_run_data(item.product, item.total_quantity)
    end
  end

  def id; end
end
