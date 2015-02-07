class ItemFinder
  attr_reader :ability

  def initialize(ability)
    @ability = ability
  end

  def bakeries
    Bakery.accessible_by(ability)
  end

  def clients
    Client.accessible_by(ability)
  end

  def products
    Product.accessible_by(ability)
  end

  def ingredients
    Ingredient.accessible_by(ability)
  end

  def recipes
    Recipe.accessible_by(ability)
  end

  def routes
    Route.accessible_by(ability)
  end

  def shipments
    Shipment.accessible_by(ability)
  end

  def orders
    Order.accessible_by(ability)
  end

  def users
    User.accessible_by(ability)
  end

  def inclusionables
    items = [ingredients, recipes].reduce([]) do |collection, objects|
      collection + objects.all.map do |o|
        [o.name, "#{o.id}-#{o.class}"]
      end
    end
    items.sort do |a, b|
      a[0] <=> b[0]
    end
  end
end
