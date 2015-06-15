class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:edit, :update, :destroy]
  after_action :verify_authorized
  after_action :verify_policy_scoped
  decorates_assigned :products, :product

  def index
    authorize Product
    @products = policy_scope(Product).order_by_name
  end

  def new
    @product = policy_scope(Product).build(unit: :kg)
    authorize @product
  end

  def create
    @product = policy_scope(Product).build(product_params)
    authorize @product
    if @product.save
      flash[:notice] = "You have created #{@product.name}."
      redirect_to edit_product_path(@product)
    else
      render 'new'
    end
  end

  def edit
    authorize @product
  end

  def update
    authorize @product
    if @product.update(product_params)
      flash[:notice] = "You have updated #{@product.name}."
      redirect_to edit_product_path(@product)
    else
      render 'edit'
    end
  end

  def destroy
    authorize @product
    @product.destroy!
    flash[:notice] = "You have deleted #{@product.name}."
    redirect_to products_path
  end

  private

  def set_product
    @product = policy_scope(Product).find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name, :product_type, :weight, :unit, :description, :over_bake, :motherdough_id, :inclusion_id, :base_price,
      :sku, :batch_recipe, price_variants_attributes: [:id, :quantity, :price, :_destroy]
    )
  end
end
