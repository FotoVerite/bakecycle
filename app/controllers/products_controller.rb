class ProductsController < ApplicationController
  before_action :set_product, only: %i[costing edit papertrail update destroy]
  decorates_assigned :products, :product

  def index
    authorize Product
    @products = policy_scope(Product)
      .where(removed: false)
      .order_by_name
      .paginate(page: params[:page])
  end

  def new
    @product = policy_scope(Product).build(unit: :kg)
    authorize @product
  end

  def created_at
    authorize Product
    @date = date_query
    @products = policy_scope(Product)
      .created_at_date(@date)
      .paginate(page: params[:page])
  end

  def create
    @product = policy_scope(Product).build(product_params)
    authorize @product
    if @product.save
      flash[:notice] = "You have created #{@product.name}."
      redirect_to edit_product_path(@product)
    else
      render "new"
    end
  end

  def edit
    authorize @product
  end

  def updated_at
    authorize Product
    @date = date_query
    @products = policy_scope(Product)
      .updated_at_date(@date)
      .paginate(page: params[:page])
  end

  def update
    authorize @product
    if @product.update(product_params)
      flash[:notice] = "You have updated #{@product.name}."
      redirect_to edit_product_path(@product)
    else
      render "edit"
    end
  end

  def destroy
    authorize @product
    if @product.destroy
      flash[:notice] = "You have deleted #{@product.name}."
      redirect_to products_path
    else
      render "edit"
    end
  end

  def papertrail
    authorize @product, :index?
  end

  def costing
    authorize @product, :index?
    @costing = CostingRecipeData.new(@product, 1)
  end

  private

  def set_product
    @product = policy_scope(Product).find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name, :product_type, :weight, :unit, :description, :over_bake,
      :motherdough_id, :inclusion_id, :base_price, :sku, :batch_recipe,
      price_variants_attributes: %i[id client_id quantity price _destroy]
    )
  end

  def date_query
    Chronic.parse(params[:date] || params[:id]) || Time.zone.today
  end
end
