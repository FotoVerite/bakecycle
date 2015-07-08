class UserPolicy < ApplicationPolicy
  def index?
    admin? || read_permission?
  end

  def show?
    admin? || record_is_self? || (read_permission? && belongs_to_bakery?)
  end

  def create?
    admin? || manage_bakery_record?
  end

  def new?
    admin? || manage_permission?
  end

  def update?
    admin? || record_is_self? || manage_bakery_record?
  end

  def edit?
    update?
  end

  def destroy?
    admin? || record_is_self? || manage_bakery_record?
  end

  def send_email?
    user.admin? || user.manage_permission? && record.invited_to_sign_up?
  end

  def manage_permission?
    admin? || user.user_permission == 'manage'
  end

  def permitted_attributes
    attributes = [:name, :email, :password, :password_confirmation]
    attributes << :bakery_id if admin?
    attributes << :user_permission if manage_permission?
    attributes << :product_permission if manage_permission?
    attributes << :bakery_permission if manage_permission?
    attributes << :client_permission if manage_permission?
    attributes
  end

  private

  def record_is_self?
    user == record
  end

  def manage_bakery_record?
    belongs_to_bakery? && manage_permission?
  end

  def read_permission?
    %w(read manage).include?(user.user_permission)
  end

  class Scope < Scope
    def resolve
      return scope.all if admin?
      return scope.none unless user.bakery
      return scope.where(bakery_id: user.bakery_id) if read_permission?
      scope.where(id: user.id)
    end

    def read_permission?
      %w(read manage).include?(user.user_permission)
    end
  end
end
