class UserDecorator < Draper::Decorator
  delegate_all

  def bakery_name
    bakery.name if bakery
  end
end
