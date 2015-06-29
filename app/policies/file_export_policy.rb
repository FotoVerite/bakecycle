class FileExportPolicy < ApplicationPolicy
  def show?
    admin? || belongs_to_bakery?
  end

  class Scope < Scope
    def resolve
      return scope.all if admin?
      scope.where(bakery_id: user.bakery_id)
    end
  end
end
