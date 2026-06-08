# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :set_product, only: %i[costing edit orders papertrail show update destroy]
  before_action :set_clients, only: %i[new edit create update]
  before_action :ensure_all_clients_price_variant, only: %i[edit]
  before_action :skip_policy_scope, only: %i[
    weekly_daily_report print_weekly_daily_report
    pricing_report
    products_per_client_per_week
    print_products_per_client_per_week
  ]
  decorates_assigned :products, :product

  def index
    authorize Product
    if params[:active] != "any"
      @products = policy_scope(Product)
        .where(removed: false, inactive: params[:active] || false)
        .order_by_name
        .paginate(page: params[:page])
    else
      @products = policy_scope(Product)
        .where(removed: false)
        .order_by_name
        .paginate(page: params[:page])
    end
  end

  def new
    @product = policy_scope(Product).build(unit: :kg)
    authorize @product
    ensure_all_clients_price_variant
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
      ensure_all_clients_price_variant
      render "new", status: :unprocessable_content
    end
  end

  def show
    authorize @product
  end

  def edit
    authorize @product
  end

  def orders
    authorize @product, :index?
    @orders = @product.orders_in_use
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
      ensure_all_clients_price_variant
      render "edit", status: :unprocessable_content
    end
  end

  def destroy
    authorize @product
    if @product.destroy
      flash[:notice] = "You have deleted #{@product.name}."
      redirect_to products_path, status: :see_other
    else
      render "edit", status: :unprocessable_content
    end
  end

  def papertrail
    authorize @product, :index?
  end

  def costing
    authorize @product, :index?
    @costing = CostingRecipeData.new(@product, 1)
  end

  def weekly_daily_report
    authorize Product, :index?
    @date = date_query
  end

  def print_weekly_daily_report
    authorize Product, :index?
    @date = date_query
    generator = ProductTotalsGenerator.new(current_bakery, date_query, params[:type])
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  def pricing_report
    authorize Product, :index?
    generator = ProductPricingGenerator.new(current_bakery)
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  def products_per_client_per_week
    authorize Product, :index?
    @date = date_query
  end

  def print_products_per_client_per_week
    authorize Product, :index?
    generator = ClientsPerProductForWeekGenerator.new(current_bakery, date_query)
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  private

  def set_product
    @product = policy_scope(Product).includes(price_variants: :client).find(params[:id])
  end

  def set_clients
    @clients = ItemFinder.new(current_user).clients.order(name: :asc)
  end

  def ensure_all_clients_price_variant
    return if @product.price_variants.any? { |pv| pv.client_id.nil? }

    @product.price_variants.build(quantity: 1, price: 0)
  end

  def product_params
    params.require(:product).permit(
      :cog, :name, :product_type, :weight, :unit, :description, :over_bake,
      :motherdough_id, :inclusion_id, :base_price, :sku, :batch_recipe,
      :public,
      :inactive,
      :lead_days_override,
      price_variants_attributes: %i[id client_id quantity price _destroy]
    )
  end

  def date_query
    parsed_date_param(:date, :id)
  end
end
