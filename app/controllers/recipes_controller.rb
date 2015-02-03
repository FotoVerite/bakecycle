class RecipesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  decorates_assigned :recipes, :recipe

  def index
  end

  def new
    @inclusionable = RecipeItem.inclusionable_items
  end

  def create
    if @recipe.save
      flash[:notice] = "You have created #{@recipe.name}."
      redirect_to edit_recipe_path(@recipe)
    else
      @inclusionable = RecipeItem.inclusionable_items
      render 'new'
    end
  end

  def edit
    @inclusionable = RecipeItem.inclusionable_items
  end

  def update
    if @recipe.update(recipe_params)
      flash[:notice] = "You have updated #{@recipe.name}."
      redirect_to edit_recipe_path(@recipe)
    else
      @inclusionable = RecipeItem.inclusionable_items
      render 'edit'
    end
  end

  def destroy
    @recipe.destroy!
    flash[:notice] = "You have deleted #{@recipe.name}"
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
