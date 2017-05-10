class RecipesController < ApplicationController
  before_action :set_recipe, only: [:edit, :papertrail, :update, :destroy]
  decorates_assigned :recipes, :recipe

  def index
    authorize Recipe
    @recipes = policy_scope(Recipe).order_by_name
  end

  def new
    @recipe = policy_scope(Recipe).build(recipe_type: :dough)
    authorize @recipe
  end

  def create
    @recipe = policy_scope(Recipe).build(recipe_params)
    authorize @recipe
    if @recipe.save
      flash[:notice] = "You have created #{@recipe.name}."
      redirect_to edit_recipe_path(@recipe)
    else
      render "new"
    end
  end

  def created_at
    authorize Recipe
    @date = date_query
    @recipes = policy_scope(Recipe)
      .created_at_date(@date)
      .paginate(page: params[:page])
  end

  def edit
    authorize @recipe
  end

  def updated_at
    authorize Recipe
    @date = date_query
    @recipes = policy_scope(Recipe)
      .updated_at_date(@date)
      .paginate(page: params[:page])
  end

  def update
    authorize @recipe
    if @recipe.update(recipe_params)
      flash[:notice] = "You have updated #{@recipe.name}."
      redirect_to edit_recipe_path(@recipe)
    else
      render "edit"
    end
  end

  def destroy
    authorize @recipe
    if @recipe.destroy
      flash[:notice] = "You have deleted #{@recipe.name}"
      redirect_to recipes_path
    else
      render "edit"
    end
  end

  def papertrail
    authorize @recipe, :index?
  end

  private

  def set_recipe
    @recipe = policy_scope(Recipe).find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(
      :name, :note, :mix_size, :mix_size_unit, :recipe_type, :lead_days,
      recipe_items_attributes: [:id, :inclusionable_id_type, :bakers_percentage, :sort_id, :_destroy]
    )
  end

  def date_query
    Chronic.parse(params[:date] || params[:id]) || Time.zone.today
  end
end
