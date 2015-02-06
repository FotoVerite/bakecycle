class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user && user.persisted?

    # Users
    can [:read, :update], User, id: user.id
    can :manage, User, bakery: user.bakery if user.bakery
    cannot :destroy, User, id: user.id if user.bakery
    can :manage, User if user.admin?

    # Clients
    can :manage, Client, bakery: user.bakery if user.bakery

    # Shipments
    can :manage, Shipment, bakery: user.bakery if user.bakery

    # Ingredients
    can :manage, Ingredient, bakery: user.bakery if user.bakery

    # Recipes
    can :manage, Recipe, bakery: user.bakery if user.bakery

    # Routes
    can :manage, Route, bakery: user.bakery if user.bakery

    # Products
    can :manage, Product, bakery: user.bakery if user.bakery

    # Orders
    can :manage, Order, bakery: user.bakery if user.bakery

    # Bakeries
    can [:read, :update], Bakery, id: user.bakery.id if user.bakery
    can :manage, Bakery if user.admin?
  end
end
