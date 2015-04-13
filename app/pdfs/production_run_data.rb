class ProductionRunData
  attr_reader :bakery
  def initialize(production_run)
    @production_run = production_run
    @run_items = production_run.run_items
    @bakery = production_run.bakery
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
    @run_items.map do |items|
      { name: items.product.name, quantity: items.total_quantity }
    end
  end

  def motherdoughs
    @run_items.map do |item|
      item.product.motherdough if item.product.motherdough.present?
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
