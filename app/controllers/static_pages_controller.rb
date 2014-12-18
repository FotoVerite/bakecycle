class StaticPagesController < ApplicationController
  def index
    @ingredients_size = Ingredient.count
    @recipes_size = Recipe.count
    @products_size = Product.count
    @routes_size = Route.count
    @clients_size = Client.count
    @orders_size = Order.count
  end
end
