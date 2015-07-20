class DemoCreator
  DEMO_DATA_YAML = 'config/demo_data.yml'

  attr_reader :kickoff, :bakery

  def initialize(bakery)
    @bakery = bakery
    @kickoff = @bakery.kickoff_time + 1.hour
  end

  def run
    ActiveRecord::Base.transaction do
      import
    end
  end

  def import
    import_objects(:clients)
    import_objects(:routes)
    import_objects(:ingredients)
    import_objects(:recipes)
    import_recipe_items
    import_products
    import_price_variants
    import_orders
    import_order_items
    run_one_week_of_kickoff
  end

  private

  def demo_data
    @_demo_data ||= YAML.load_file(Rails.root.join(DEMO_DATA_YAML))
  end

  def imported(name)
    @_imported ||= {}
    @_imported[name] ||= {}
  end

  def import_objects(name)
    model = name.to_s.classify.constantize
    demo_data[name].each do |demo_id, data|
      if block_given?
        merged = yield(data)
      else
        merged = data.merge(bakery: bakery)
      end
      imported(name)[demo_id] = model.create!(merged)
    end
  end

  def import_recipe_items
    import_objects(:recipe_items) do |data|
      inclusionable_id = data.delete(:inclusionable_id)
      if data[:inclusionable_type] == 'Recipe'
        inclusionable = imported(:recipes)[inclusionable_id]
      else
        inclusionable = imported(:ingredients)[inclusionable_id]
      end
      data.merge(
        inclusionable_id: inclusionable.id,
        recipe_id: imported(:recipes)[data[:recipe_id]].id
      )
    end
  end

  def import_products
    import_objects(:products) do |data|
      motherdough_id = imported(:recipes)[data[:motherdough_id]].id if data[:motherdough_id]
      inclusion_id = imported(:recipes)[data[:inclusion_id]].id if data[:inclusion_id]
      data.merge(
        bakery: bakery,
        motherdough_id: motherdough_id,
        inclusion_id: inclusion_id
      )
    end
  end

  def import_price_variants
    import_objects(:price_variants) do |data|
      client_id = imported(:clients)[data[:client_id]].id if data[:client_id]
      product_id = imported(:products)[data[:product_id]].id
      data.merge(
        client_id: client_id,
        product_id: product_id
      )
    end
  end

  def import_orders
    import_objects(:orders) do |data|
      client = imported(:clients)[data.delete(:client_id)]
      route = imported(:routes)[data.delete(:route_id)]
      data.merge(
        bakery: bakery,
        client: client,
        route: route
      )
    end
  end

  def import_order_items
    import_objects(:order_items) do |data|
      order = imported(:orders)[data.delete(:order_id)]
      product = imported(:products)[data.delete(:product_id)]
      data.merge(
        order: order,
        product: product
      )
    end
  end

  def run_one_week_of_kickoff
    (0..7).to_a.reverse_each do |days|
      date = Time.zone.today - days.days
      KickoffService.new(@bakery, process_time(date)).run
    end
  end

  def process_time(date)
    Time.zone.local(date.year, date.month, date.day, kickoff.hour, kickoff.min, kickoff.sec)
  end
end
