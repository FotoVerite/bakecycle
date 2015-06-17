class ProductPolicy < ApplicationPolicy
  attr_reader :user, :record

  def index?
    (user.admin? || read_permission?) && user.bakery
  end

  def new?
    (user.admin? || manage_permission?) && user.bakery
  end

  def show?
    (user.admin? || read_permission?) && belongs_to_bakery?
  end

  def create?
    (user.admin? || manage_permission?) && belongs_to_bakery?
  end

  def update?
    (user.admin? || manage_permission?) && belongs_to_bakery?
  end

  def edit?
    (user.admin? || manage_permission?) && belongs_to_bakery?
  end

  def destroy?
    (user.admin? || manage_permission?) && belongs_to_bakery?
  end

  def manage_permission?
    user.product_permission == 'manage'
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
      user.bakery && (user.admin? || %w(read manage).include?(user.product_permission))
    end
  end
end
