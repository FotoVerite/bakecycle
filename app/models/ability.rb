class Ability
  include CanCan::Ability
  attr_reader :user

  def initialize(user)
    @user = user
    return unless user && user.persisted?
    can :manage, ProductionRun, bakery_id: user.bakery_id if user.bakery
    can :manage, :resque if user.admin?
  end
end
