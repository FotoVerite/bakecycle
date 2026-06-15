# frozen_string_literal: true

class UserPinnedActionPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    record.user_id == user.id
  end

  def destroy?
    update?
  end

  class Scope < Scope
    def resolve
      scope.where(user_id: user.id)
    end
  end
end
