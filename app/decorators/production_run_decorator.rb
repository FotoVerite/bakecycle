class ProductionRunDecorator < Draper::Decorator
  delegate_all
  decorates_association :run_items

  def available_products
    h.item_finder.products.order(:name) - object.run_items.map(&:product)
  end
end
