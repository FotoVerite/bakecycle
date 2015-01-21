class OrderDecorator < Draper::Decorator
  delegate_all
  decorates_association :order_items
end
