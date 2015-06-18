class Ability
  include CanCan::Ability
  attr_reader :user

  def initialize(user)
    @user = user
    return unless user && user.persisted?

    can :manage, Client, bakery_id: user.bakery.id if user.bakery
    can :manage, Shipment, bakery_id: user.bakery.id if user.bakery
    can :manage, Route, bakery_id: user.bakery.id if user.bakery
    can :manage, Order, bakery_id: user.bakery.id if user.bakery
    can :manage, ProductionRun, bakery_id: user.bakery.id if user.bakery
    can :manage, FileExport, bakery_id: user.bakery.id if user.bakery
    can :manage, :resque if user.admin?
  end
end
