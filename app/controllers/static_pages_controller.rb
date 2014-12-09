class StaticPagesController < ApplicationController
  def index
    @ingredients_size = Ingredient.count
    @recipes_size = Recipe.count
    @products_size = Product.count
  end
end
