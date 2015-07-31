class ProductionRunPolicy < ApplicationPolicy
  def index?
    (admin? || can_read?) && bakery?
  end

  def edit?
    (admin? || can_manage?) && belongs_to_bakery?
  end

  def update?
    edit?
  end

  def reset?
    edit?
  end

  def print?
    (admin? || can_read?) && belongs_to_bakery?
  end

  def can_print?
    (admin? || can_read?) && bakery?
  end

  private

  def can_manage?
    user.production_permission == "manage"
  end

  def bakery?
    user.bakery.present?
  end

  def belongs_to_bakery?
    record.bakery == user.bakery
  end

  def can_read?
    %w(read manage).include?(user.production_permission)
  end

  class Scope < Scope
    def resolve
      return scope.none if user.bakery.nil?
      return scope.where(bakery_id: user.bakery_id) if read_permission? || admin?
      scope.none
    end

    def read_permission?
      %w(read manage).include?(user.production_permission)
    end
  end
end
