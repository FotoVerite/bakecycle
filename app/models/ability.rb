class Ability
  include CanCan::Ability
  def initialize(user)
    return unless user && user.persisted?

    # users
    can :manage, User, id: user.id
    can :manage, User, bakery: user.bakery if user.bakery
    can :manage, User if user.admin?

    if user.admin?
      can :manage, Bakery
    end

    if user.bakery
      can :manage, [
        Client,
        Ingredient,
        Order,
        OrderCreator,
        OrderItem,
        PriceVarient,
        Product,
        Recipe,
        RecipeItem,
        Route,
        Shipment,
        ShipmentItem,
      ]
    end
  end
end
