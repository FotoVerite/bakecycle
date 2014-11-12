class StaticPagesController < ApplicationController
  def index
    @ingredients_size = Ingredient.all.size
  end
end
