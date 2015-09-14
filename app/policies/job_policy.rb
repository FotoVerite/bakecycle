class JobPolicy < ApplicationPolicy
  def dashboard?
    admin?
  end
end
