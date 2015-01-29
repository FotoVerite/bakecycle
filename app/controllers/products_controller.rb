class ProductsController < ApplicationController
  before_action :authenticate_user!

  def index
    @products = Product.all.decorate
  end

  def new
    @product = Product.new
    @recipes = Recipe.all
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      flash[:notice] = "You have created #{@product.name}."
      redirect_to edit_product_path(@product)
    else
      @recipes = Recipe.all
      render 'new'
    end
  end

  def edit
    @product = Product.find(params[:id])
    @recipes = Recipe.all
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      flash[:notice] = "You have updated #{@product.name}."
      redirect_to edit_product_path(@product)
    else
      @recipes = Recipe.all
      render 'edit'
    end
  end

  def destroy
    Product.destroy(params[:id])
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
