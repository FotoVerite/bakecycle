class RecipesController < ApplicationController
  before_action :authenticate_user!

  def index
    @recipes = Recipe.all.decorate
  end

  def new
    @recipe = Recipe.new
    @inclusionable = RecipeItem.inclusionable_items
  end

  def create
    @recipe = Recipe.new(recipe_params)
    if @recipe.save
      flash[:notice] = "You have created #{@recipe.name}."
      redirect_to edit_recipe_path(@recipe)
    else
      @inclusionable = RecipeItem.inclusionable_items
      render 'new'
    end
  end

  def edit
    @recipe = Recipe.find(params[:id])
    @inclusionable = RecipeItem.inclusionable_items
  end

  def update
    @recipe = Recipe.find(params[:id])
    if @recipe.update(recipe_params)
      flash[:notice] = "You have updated #{@recipe.name}."
      redirect_to edit_recipe_path(@recipe)
    else
      @inclusionable = RecipeItem.inclusionable_items
      render 'edit'
    end
  end

  def destroy
    Recipe.destroy(params[:id])
    redirect_to recipes_path
  end

  private

  def recipe_params
    params.require(:recipe).permit(
      :name, :note, :mix_size, :mix_size_unit, :recipe_type, :lead_days,
      recipe_items_attributes: [:id, :inclusionable_id_type, :bakers_percentage, :_destroy]
    )
  end
end
