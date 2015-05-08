class ProductsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  decorates_assigned :products, :product

  def index
    @products = @products.order_by_name
  end

  def new
    @product.unit = :kg
  end

  def create
    if @product.save
      flash[:notice] = "You have created #{@product.name}."
      redirect_to edit_product_path(@product)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      flash[:notice] = "You have updated #{@product.name}."
      redirect_to edit_product_path(@product)
    else
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
      :name, :product_type, :weight, :unit, :description, :over_bake, :motherdough_id, :inclusion_id, :base_price,
      :sku, price_variants_attributes: [:id, :quantity, :price, :_destroy]
    )
  end
end
