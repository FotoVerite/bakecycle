class StaticPagesController < ApplicationController
  def index
    active_nav(:dashboard)
    @ingredients_size = Ingredient.count
    @recipes_size = Recipe.count
    @products_size = Product.count
    @routes_size = Route.count
    @clients_size = Client.count
    @orders_size = Order.count
    @shipments_size = Shipment.count
  end
end
