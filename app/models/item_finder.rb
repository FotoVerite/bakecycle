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
    Pundit.policy_scope!(ability.user, Product)
  end

  def ingredients
    Pundit.policy_scope!(ability.user, Ingredient)
  end

  def recipes
    Pundit.policy_scope!(ability.user, Recipe)
  end

  def routes
    Route.accessible_by(ability)
  end

  def production_runs
    ProductionRun.accessible_by(ability)
      .includes(run_items: [:product])
  end

  def shipments
    Shipment.accessible_by(ability)
  end

  def shipment_items
    ShipmentItem
      .joins(:shipment)
      .where(shipments: ability.attributes_for(:read, Shipment))
  end

  def orders
    Order.accessible_by(ability)
  end

  def users
    Pundit.policy_scope!(ability.user, User)
  end
end
