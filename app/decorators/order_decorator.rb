class OrderDecorator < Draper::Decorator
  delegate_all
  decorates_association :order_items

  def type
    order_type.humanize(capitalize: false).titleize
  end
end
