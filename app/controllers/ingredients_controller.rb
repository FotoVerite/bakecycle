class IngredientsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
  end

  def new
  end

  def create
    if @ingredient.save
      flash[:notice] = "You have created #{@ingredient.name}."
      redirect_to edit_ingredient_path(@ingredient)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @ingredient.update(ingredient_params)
      flash[:notice] = "You have updated #{@ingredient.name}."
      redirect_to edit_ingredient_path(@ingredient)
    else
      render 'edit'
    end
  end

  def destroy
    @ingredient.destroy!
    flash[:notice] = "You have deleted #{@ingredient.name}"
    redirect_to ingredients_path
  end

  private

  def ingredient_params
    params.require(:ingredient).permit(:name, :price, :measure, :unit, :ingredient_type, :description)
  end
end
