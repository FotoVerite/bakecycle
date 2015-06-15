class UserDecorator < Draper::Decorator
  delegate_all

  def bakery_name
    bakery.name if bakery
  end

  def access_level
    User::ACCESS_LEVELS.map { |access| [access.to_s.humanize, access] }
  end
end
