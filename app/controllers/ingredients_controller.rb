class IngredientsController < ApplicationController
  def index
    @ingredients = Ingredient.all
  end

  def new
    @ingredient = Ingredient.new
  end

  def create
    @ingredient = Ingredient.new(ingredient_params)

    if @ingredient.save
      flash[:notice] = "You have created #{@ingredient.name}."
      redirect_to edit_ingredient_path(@ingredient)
    else
      render 'new'
    end
  end

  def edit
    @ingredient = Ingredient.find(params[:id])
  end

  def update
    @ingredient = Ingredient.find(params[:id])
    if @ingredient.update(ingredient_params)
      flash[:notice] = "You have updated #{@ingredient.name}."
      redirect_to edit_ingredient_path(@ingredient)
    else
      render 'edit'
    end
  end

  def destroy
    Ingredient.destroy(params[:id])
    redirect_to ingredients_path
  end

  private

  def ingredient_params
    params.require(:ingredient).permit(:name, :price, :measure, :unit, :ingredient_type, :description)
  end
end
