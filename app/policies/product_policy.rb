class ProductPolicy < ApplicationPolicy
  def index?
    (admin? || read_permission?) && user.bakery
  end

  def new?
    manage_permission? && user.bakery
  end

  def show?
    (admin? || read_permission?) && belongs_to_bakery?
  end

  def created_at?
    (admin? || read_permission?) && user.bakery
  end

  def updated_at?
    (admin? || read_permission?) && user.bakery
  end

  def create?
    manage_permission? && belongs_to_bakery?
  end

  def update?
    manage_permission? && belongs_to_bakery?
  end

  def edit?
    manage_permission? && belongs_to_bakery?
  end

  def destroy?
    manage_permission? && belongs_to_bakery?
  end

  def manage_permission?
    admin? || (user.product_permission == "manage")
  end

  def dashboard?
    index?
  end

  private

  def read_permission?
    %(read manage).include?(user.product_permission)
  end

  class Scope < Scope
    def resolve
      return scope.where(bakery_id: user.bakery_id) if read_permission?
      scope.none
    end

    def read_permission?
      user.bakery && (admin? || %w[read manage].include?(user.product_permission))
    end
  end
end
