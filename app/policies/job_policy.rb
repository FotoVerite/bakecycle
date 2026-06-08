# frozen_string_literal: true

class JobPolicy < ApplicationPolicy
  def dashboard?
    admin?
  end
end
