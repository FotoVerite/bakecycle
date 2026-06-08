# frozen_string_literal: true

class UserDecorator < Draper::Decorator
  delegate_all

  def bakery_name
    bakery&.name
  end

  def access_level
    User::ACCESS_LEVELS.map { |access| [access.to_s.humanize, access] }
  end
end
