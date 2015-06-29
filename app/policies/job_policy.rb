class JobPolicy < ApplicationPolicy
  def index?
    admin?
  end
end
