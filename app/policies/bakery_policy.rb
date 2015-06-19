class BakeryPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def create?
    admin?
  end

  def show?
    admin? || (read_permission? && current_bakery?)
  end

  def new?
    admin?
  end

  def update?
    admin? || (manage_permission? && current_bakery?)
  end

  def edit?
    admin? || (manage_permission? && current_bakery?)
  end

  def destroy?
    admin?
  end

  def manage_permission?
    user.bakery_permission == 'manage'
  end

  def current_bakery?
    user.bakery == record
  end

  private

  def read_permission?
    %w(read manage).include?(user.bakery_permission)
  end

  class Scope < Scope
    def resolve
      return scope.all if admin?
      return scope.where(id: user.bakery_id) if read_permission?
      scope.none
    end

    def read_permission?
      %w(read manage).include?(user.bakery_permission)
    end
  end
end
