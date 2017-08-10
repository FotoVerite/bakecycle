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
    user.bakery_permission == "manage"
  end

  def current_bakery?
    user.bakery == record
  end

  def change_plan?
    admin?
  end

  def permitted_attributes
    attributes = %i[
      name logo email phone_number address_street_1 address_street_2 address_city
      address_state address_zipcode kickoff_time quickbooks_account group_preferments
    ]
    attributes << :plan_id if change_plan?
    attributes
  end

  def dashboard?
    index?
  end

  private

  def read_permission?
    %w[read manage].include?(user.bakery_permission)
  end

  class Scope < Scope
    def resolve
      return scope.all if admin?
      return scope.where(id: user.bakery_id) if read_permission?
      scope.none
    end

    def read_permission?
      %w[read manage].include?(user.bakery_permission)
    end
  end
end
