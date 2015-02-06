class ProductsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  decorates_assigned :products, :product

  def index
  end

  def new
    @recipes = Recipe.accessible_by(current_ability)
  end

  def create
    if @product.save
      flash[:notice] = "You have created #{@product.name}."
      redirect_to edit_product_path(@product)
    else
      @recipes = Recipe.accessible_by(current_ability)
      render 'new'
    end
  end

  def edit
    @recipes = Recipe.accessible_by(current_ability)
  end

  def update
    if @product.update(product_params)
      flash[:notice] = "You have updated #{@product.name}."
      redirect_to edit_product_path(@product)
    else
      @recipes = Recipe.accessible_by(current_ability)
      render 'edit'
    end
  end

  def destroy
    @product.destroy!
    flash[:notice] = "You have deleted #{@product.name}."
    redirect_to products_path
  end

  private

  def product_params
    params.require(:product).permit(
      :name, :product_type, :weight, :unit, :description, :extra_amount, :motherdough_id, :inclusion_id, :base_price,
      price_varients_attributes: [:id, :quantity, :price, :effective_date, :_destroy]
    )
  end
end
