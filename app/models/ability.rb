class Ability
  include CanCan::Ability
  attr_reader :user

  def initialize(user)
    @user = user
    return unless user && user.persisted?
    if user.bakery
      can :manage, Client, bakery_id: user.bakery_id
      can :manage, Shipment, bakery_id: user.bakery_id
      can :manage, Route, bakery_id: user.bakery_id
      can :manage, Order, bakery_id: user.bakery_id
      can :manage, ProductionRun, bakery_id: user.bakery_id
    end
    can :manage, :resque if user.admin?
  end
end
