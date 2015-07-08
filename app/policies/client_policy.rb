class ClientPolicy < ApplicationPolicy
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
    (admin? || manage_permission?) && belongs_to_bakery?
  end

  def edit?
    (admin? || manage_permission?) && belongs_to_bakery?
  end

  def destroy?
    (admin? || manage_permission?) && belongs_to_bakery?
  end

  def manage_permission?
    user.client_permission == 'manage'
  end

  private

  def read_permission?
    %(read manage).include?(user.client_permission)
  end

  class Scope < Scope
    def resolve
      return scope.where(bakery_id: user.bakery_id) if read_permission?
      scope.none
    end

    def read_permission?
      user.bakery && (admin? || %w(read manage).include?(user.client_permission))
    end
  end
end
