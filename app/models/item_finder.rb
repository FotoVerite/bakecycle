class ItemFinder
  attr_reader :ability

  def initialize(ability)
    @ability = ability
  end

  def bakeries
    Pundit.policy_scope!(ability.user, Bakery)
  end

  def clients
    Pundit.policy_scope!(ability.user, Client)
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
    Pundit.policy_scope!(ability.user, Shipment)
  end

  def orders
    Pundit.policy_scope!(ability.user, Order)
  end

  def users
    Pundit.policy_scope!(ability.user, User)
  end
end
