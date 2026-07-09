# frozen_string_literal: true

class FileExportPolicy < ApplicationPolicy
  def index?
    admin? || user.bakery.present?
  end

  def show?
    admin? || record.user_id == user.id
  end

  class Scope < Scope
    def resolve
      return scope.all if admin?

      # Exports are private to the person who requested them, not shared across
      # the bakery. Scoping by user_id also transitively scopes by bakery.
      scope.where(user_id: user.id)
    end
  end
end
