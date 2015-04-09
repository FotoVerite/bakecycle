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

  def production_runs
    ProductionRun.accessible_by(ability)
  end

  def shipments
    Shipment.accessible_by(ability)
  end

  def shipment_items
    ShipmentItem.joins(:shipment).where(shipments: ability.attributes_for(:read, Shipment))
  end

  def orders
    Order.accessible_by(ability)
  end

  def users
    User.accessible_by(ability)
  end
end
