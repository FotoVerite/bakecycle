class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user && user.persisted?

    # Users
    can [:read, :update], User, id: user.id
    can :manage, User, bakery_id: user.bakery.id if user.bakery
    cannot :destroy, User, id: user.id if user.bakery
    can :manage, User if user.admin?

    # Clients
    can :manage, Client, bakery_id: user.bakery.id if user.bakery

    # Shipments
    can :manage, Shipment, bakery_id: user.bakery.id if user.bakery

    # Ingredients
    can :manage, Ingredient, bakery_id: user.bakery.id if user.bakery

    # Recipes
    can :manage, Recipe, bakery_id: user.bakery.id if user.bakery

    # Routes
    can :manage, Route, bakery_id: user.bakery.id if user.bakery

    # Products
    can :manage, Product, bakery_id: user.bakery.id if user.bakery

    # Orders
    can :manage, Order, bakery_id: user.bakery.id if user.bakery

    # Bakeries
    can [:read, :update, :mybakery], Bakery, id: user.bakery.id if user.bakery
    can :manage, Bakery if user.admin?
  end
end
