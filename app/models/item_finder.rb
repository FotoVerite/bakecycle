class ItemFinder
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def bakeries
    Pundit.policy_scope!(user, Bakery)
  end

  def clients
    Pundit.policy_scope!(user, Client)
  end

  def products
    Pundit.policy_scope!(user, Product)
  end

  def ingredients
    Pundit.policy_scope!(user, Ingredient)
  end

  def recipes
    Pundit.policy_scope!(user, Recipe)
  end

  def routes
    Pundit.policy_scope!(user, Route)
  end

  def production_runs
    Pundit.policy_scope!(user, ProductionRun)
  end

  def shipments
    Pundit.policy_scope!(user, Shipment)
  end

  def orders
    Pundit.policy_scope!(user, Order)
  end

  def users
    Pundit.policy_scope!(user, User)
  end

  def vendors
    Pundit.policy_scope!(user, Vendor)
  end
  
end
