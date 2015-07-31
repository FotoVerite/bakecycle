class ShippingPolicy < ApplicationPolicy
  def index?
    (admin? || read_permission?) && user.bakery
  end

  def new?
    (admin? || manage_permission?) && user.bakery
  end

  def show?
    (admin? || read_permission?) && belongs_to_bakery?
  end

  def create?
    (admin? || manage_permission?) && belongs_to_bakery?
  end

  def update?
    create?
  end

  def edit?
    create?
  end

  def destroy?
    create?
  end

  def manage_permission?
    user.shipping_permission == "manage"
  end

  def print?
    index?
  end

  private

  def read_permission?
    %(read manage).include?(user.shipping_permission)
  end

  class Scope < Scope
    def resolve
      return scope.where(bakery_id: user.bakery_id) if read_permission?
      scope.none
    end

    def read_permission?
      user.bakery && (admin? || %w(read manage).include?(user.shipping_permission))
    end
  end
end
