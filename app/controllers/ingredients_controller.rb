class IngredientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ingredient, only: [:edit, :update, :destroy]
  after_action :verify_authorized
  after_action :verify_policy_scoped

  def index
    authorize Ingredient
    @ingredients = policy_scope(Ingredient).order_by_name
  end

  def new
    @ingredient = policy_scope(Ingredient).build
    authorize @ingredient
  end

  def create
    @ingredient = policy_scope(Ingredient).build(ingredient_params)
    authorize @ingredient
    if @ingredient.save
      flash[:notice] = "You have created #{@ingredient.name}."
      redirect_to edit_ingredient_path(@ingredient)
    else
      render 'new'
    end
  end

  def edit
    authorize @ingredient
  end

  def update
    authorize @ingredient
    if @ingredient.update(ingredient_params)
      flash[:notice] = "You have updated #{@ingredient.name}."
      redirect_to edit_ingredient_path(@ingredient)
    else
      render 'edit'
    end
  end

  def destroy
    authorize @ingredient
    @ingredient.destroy!
    flash[:notice] = "You have deleted #{@ingredient.name}"
    redirect_to ingredients_path
  end

  private

  def set_ingredient
    @ingredient = policy_scope(Ingredient).find(params[:id])
  end

  def ingredient_params
    params.require(:ingredient).permit(:name, :price, :measure, :unit, :ingredient_type, :description)
  end
end
