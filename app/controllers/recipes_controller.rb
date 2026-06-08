# frozen_string_literal: true

class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[edit papertrail update destroy]
  before_action :set_inclusions, only: %i[new edit create update]
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
      render "new", status: :unprocessable_content
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
      render "edit", status: :unprocessable_content
    end
  end

  def destroy
    authorize @recipe
    if @recipe.destroy
      flash[:notice] = "You have deleted #{@recipe.name}"
      redirect_to recipes_path, status: :see_other
    else
      render "edit", status: :unprocessable_content
    end
  end

  def papertrail
    authorize @recipe, :index?
  end

  private

  def set_recipe
    @recipe = policy_scope(Recipe).find(params[:id])
  end

  def set_inclusions
    ingredients = item_finder.ingredients.order(:name)
    other_recipes = item_finder.recipes.where.not(id: @recipe&.id).order(:name)

    ingredient_options = ingredients.map do |i|
      [i.name, "#{i.id}-Ingredient",
       { data: { type: i.ingredient_type.capitalize, lead_days: i.total_lead_days.to_i } }]
    end

    recipe_options = other_recipes.map do |r|
      [r.name, "#{r.id}-Recipe", { data: { type: "Recipe", lead_days: r.total_lead_days.to_i } }]
    end

    @available_inclusions = (ingredient_options + recipe_options).sort_by(&:first)
    @available_ingredients = ingredient_options
  end

  def recipe_params
    params.require(:recipe).permit(
      :name, :note, :mix_size, :mix_size_unit, :recipe_type, :lead_days,
      recipe_items_attributes: %i[id inclusionable_id_type bakers_percentage sort_id _destroy]
    )
  end

  def date_query
    parsed_date_param(:date, :id)
  end
end
