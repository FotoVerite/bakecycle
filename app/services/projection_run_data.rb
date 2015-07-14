class ProjectionRunData < ProductionRunData
  attr_reader :bakery, :recipes_collection, :projection_run, :batch_end_date

  def initialize(projection_run)
    @projection_run = projection_run
    @items = projection_run.order_items
    @bakery = projection_run.bakery
    @recipes_collection = RecipeCollection.new
    @batch_end_date = projection_run.batch_end_date
    processes_run_items
  end

  def run_date
    projection_run.start_date
  end

  def products
    projection_run.products_info.group_by do |item|
      item.product.product_type
    end
  end

  def processes_run_items
    projection_run.products_info.each do |item|
      add_to_recipe_run_data(item.product, item.total_quantity)
    end
  end

  def id
    nil
  end
end
