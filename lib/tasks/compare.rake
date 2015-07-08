task compare: :environment do
  ((Time.zone.today - 30)..Time.zone.today).map do |date|
    CompareProduction.new(date).compare
  end
end

class CompareProduction
  attr_reader :date, :bakery, :production_run, :projection

  def initialize(date)
    @date = date
    @bakery = Bakery.first
    @production_run = ProductionRun.where(bakery: bakery, date: date).first
    @projection = ProductionRunProjection.new(bakery, date)
  end

  def compare
    unless production_run
      puts "#{date} has no production run"
      return
    end

    if run_items.count != projection_items.count
      puts "#{date} product count #{run_items.count} #{projection_items.count}"
      return
    end

    match_errors
  end

  private

  def match_errors
    products.each { |product|
      error = match_items(product)
      puts error if error
    }
  end

  def run_items
    @_run_items ||= production_run.run_items.each_with_object({}) { |item, obj|
      obj[item.product] = item
    }
  end

  def projection_items
    @_projection_items ||= projection.products_info.each_with_object({}) { |item, obj|
      obj[item.product] = item
    }
  end

  def products
    @_products ||= (run_items.keys + projection_items.keys).uniq
  end

  def match_items(product)
    run_item = run_items[product]
    projection_item = projection_items[product]
    return "#{date} #{product.name} missing run_item" unless run_item
    return "#{date} #{product.name} missing projection_item" unless projection_item
    fields = CompareFields.new(date, run_item, projection_item)
    fields.order_quantity || fields.total_quantity
  end

  class CompareFields
    def initialize(date, run_item, projection_item)
      @date = date
      @run_item = run_item
      @projection_item = projection_item
    end

    def method_missing(method)
      compare(method)
    end

    def compare(field)
      run_qty = @run_item.send(field)
      prj_qty = @projection_item.send(field)
      return "#{@date} #{@run_item.product.name} #{field} #{run_qty} #{prj_qty}" unless run_qty == prj_qty
    end
  end
end
