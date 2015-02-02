class Ability
  include CanCan::Ability
  def initialize(user)
    if user.admin?
      can :manage, [Bakery, User]
    end

    if user.bakery_id
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
        ShipmentItem
      ]
    end
  end
end
