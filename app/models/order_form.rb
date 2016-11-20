class OrderForm
  extend ActiveModel::Naming
  include ActiveModel::Serialization

  attr_accessor :order
  attr_reader :item_finder

  def initialize(order:, user:)
    @order = order
    @item_finder = ItemFinder.new(user)
  end

  def available_products
    item_finder.products.includes(:price_variants).order(:name)
  end

  def available_routes
    item_finder.routes.active.order(:name)
  end

  def available_clients
    item_finder.clients.order(:name)
  end

  def serializable_hash
    hash = OrderFormSerializer.new(self).serializable_hash
    hash[:order]["kickoff_time"] = @order.bakery.kickoff_time
    hash
  end
end
