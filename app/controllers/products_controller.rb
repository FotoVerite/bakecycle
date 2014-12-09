class ProductsController < ApplicationController
  def index
    @products = Product.all
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
      :name, :product_type, :weight, :unit, :description, :extra_amount, :motherdough_id, :inclusion_id,
      product_prices_attributes: [:id, :quantity, :price, :effective_date, :_destroy]
    )
  end
end
