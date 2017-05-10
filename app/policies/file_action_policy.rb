class FileActionPolicy < ApplicationPolicy
  def index?
    (admin? || read_permission?) && user.bakery
  end

  class Scope < Scope
    def resolve
      return scope.all if admin?
      scope.where(bakery_id: user.bakery_id)
    end
  end
end
