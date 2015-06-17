class RecipesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipe, only: [:edit, :update, :destroy]
  after_action :verify_authorized
  after_action :verify_policy_scoped
  decorates_assigned :recipes, :recipe

  def index
    authorize Recipe
    @recipes = policy_scope(Recipe).order_by_name
  end

  def new
    @recipe = policy_scope(Recipe).build
    authorize @recipe
  end

  def create
    @recipe = policy_scope(Recipe).build(recipe_params)
    authorize @recipe
    if @recipe.save
      flash[:notice] = "You have created #{@recipe.name}."
      redirect_to edit_recipe_path(@recipe)
    else
      render 'new'
    end
  end

  def edit
    authorize @recipe
  end

  def update
    authorize @recipe
    if @recipe.update(recipe_params)
      flash[:notice] = "You have updated #{@recipe.name}."
      redirect_to edit_recipe_path(@recipe)
    else
      render 'edit'
    end
  end

  def destroy
    authorize @recipe
    @recipe.destroy!
    flash[:notice] = "You have deleted #{@recipe.name}"
    redirect_to recipes_path
  end

  private

  def set_recipe
    @recipe = policy_scope(Recipe).find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(
      :name, :note, :mix_size, :mix_size_unit, :recipe_type, :lead_days,
      recipe_items_attributes: [:id, :inclusionable_id_type, :bakers_percentage, :_destroy]
    )
  end
end
