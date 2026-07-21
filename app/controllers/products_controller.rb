# frozen_string_literal: true

class ProductsController < ApplicationController
  include ExportsReportable

  before_action :set_product, only: %i[costing edit orders papertrail show update destroy]
  before_action :set_clients, only: %i[new edit create update]
  before_action :ensure_all_clients_price_variant, only: %i[edit]
  before_action :skip_policy_scope, only: %i[
    product_totals_report
    product_totals_comparison
    export_product_totals
    pricing_report
    products_per_client_per_week
    print_products_per_client_per_week
  ]
  decorates_assigned :products, :product

  def index
    authorize Product
    @name_search = params[:name].to_s.strip
    scope = policy_scope(Product)
    scope = if params[:active] != "any"
      scope.where(removed: false, inactive: params[:active] || false)
    else
      scope.where(removed: false)
    end
    scope = scope.where("products.name ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(@name_search)}%") if @name_search.present?
    @products = scope.order_by_name.paginate(page: params[:page])
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
    @orders_in_use = @product.orders_in_use
    @orders = @orders_in_use.order(id: :desc).paginate(page: params[:page])
  end

  def edit
    authorize @product
  end

  def orders
    authorize @product, :index?
    @orders = @product.orders_in_use.order(id: :desc).paginate(page: params[:page])
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

  def product_totals_report
    authorize Product, :index?
    @date = date_query
    @end_date = optional_parsed_date_param(:end_date) || (@date + 6.days)
  end

  def product_totals_comparison
    authorize Product, :index?
    @start_date = optional_parsed_date_param(:date) || Time.zone.today - 13.days
    @end_date = optional_parsed_date_param(:end_date) || Time.zone.today
    @end_date = @start_date if @end_date < @start_date
    @end_date = [@end_date, @start_date + 61.days].min

    @compare_key = params[:compare].presence || "shipments"
    @diff_only = params.fetch(:diff_only, "1") == "1"

    @available_snapshots = ProductTotalsSnapshot
      .where(bakery: current_bakery)
      .where("start_date <= ? AND end_date >= ?", @end_date, @start_date)
      .order(created_at: :desc)
      .limit(45)
    # Default the baseline to the snapshot captured at the start of the range:
    # "the plan as it stood that morning". It's also one indexed SELECT versus
    # the live projection's per-day order walk (~5s on a real dataset).
    default_snapshot = @available_snapshots.find { |snapshot| snapshot.start_date <= @start_date }
    @baseline_key = params[:baseline].presence ||
      (default_snapshot ? "snapshot_#{default_snapshot.id}" : "orders")
    @source_options = comparison_source_options
    @comparison = ProductTotalsComparison.new(
      comparison_source(@baseline_key),
      comparison_source(@compare_key)
    )
  end

  def export_product_totals
    authorize Product, :index?
    generator = ProductTotalsDateRangeGenerator.new(
      current_bakery,
      date_query,
      end_date: optional_parsed_date_param(:end_date),
      source: params[:source]
    )
    create_export_and_respond(generator)
  end

  def pricing_report
    authorize Product, :index?
    generator = ProductPricingGenerator.new(current_bakery)
    create_export_and_respond(generator)
  end

  def products_per_client_per_week
    authorize Product, :index?
    @date = date_query
  end

  def print_products_per_client_per_week
    authorize Product, :index?
    generator = ClientsPerProductForWeekGenerator.new(current_bakery, date_query)
    create_export_and_respond(generator)
  end

  private

  def set_product
    scope = policy_scope(Product)
    # show/orders/costing/destroy don't render price_variants -- eager loading them there
    # was flagged by Bullet as unnecessary. edit/update (which re-renders the edit form
    # on validation failure) and papertrail all render price_variants via _form.html.erb.
    if %w[edit update papertrail].include?(action_name)
      scope = scope.includes(price_variants: :client, bake_lead_day_variants: :client)
    end
    @product = scope.find(params[:id])
  end

  # Price/bake-lead-day override selects only need active clients as choices for new
  # overrides, but an existing override can point at a client who's since gone inactive --
  # dropping that client from the options would leave the select unable to match its own
  # value, silently rebinding the override to blank ("All Clients") on next save. So the
  # list is active clients plus whichever (possibly inactive) clients this product's
  # existing overrides already reference.
  def set_clients
    active_clients = ItemFinder.new(current_user).clients.active.order(name: :asc).to_a
    @clients = @product ? active_clients_plus_referenced(active_clients) : active_clients
  end

  def active_clients_plus_referenced(active_clients)
    referenced_ids = @product.price_variants.where.not(client_id: nil).pluck(:client_id) +
      @product.bake_lead_day_variants.pluck(:client_id)
    missing_ids = referenced_ids.uniq - active_clients.map(&:id)
    return active_clients if missing_ids.empty?

    (active_clients + ItemFinder.new(current_user).clients.where(id: missing_ids)).sort_by(&:name)
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
      :pieces_per_tray,
      :bake_lead_days,
      :on_pull_list,
      :on_vienn_pick,
      price_variants_attributes: %i[id client_id quantity price _destroy],
      bake_lead_day_variants_attributes: %i[id client_id bake_lead_days _destroy]
    )
  end

  def date_query
    parsed_date_param(:date, :id)
  end

  def comparison_source(key)
    case key
    when "shipments"
      ProductTotalsComparison.live(current_bakery, @start_date, @end_date, source: "generated_invoices")
    when /\Asnapshot_(\d+)\z/
      snapshot = ProductTotalsSnapshot.find_by(bakery: current_bakery, id: Regexp.last_match(1))
      snapshot ? ProductTotalsComparison.from_snapshot(snapshot, @start_date, @end_date) : {}
    else
      ProductTotalsComparison.live(current_bakery, @start_date, @end_date, source: "order_projection")
    end
  end

  def comparison_source_options
    [["Current orders", "orders"], ["Created shipments", "shipments"]] +
      @available_snapshots.map do |snapshot|
        kind = snapshot.source == "generated_invoices" ? "shipments" : "orders"
        ["#{snapshot.created_at.strftime('%b %-d, %Y')} snapshot (#{kind})", "snapshot_#{snapshot.id}"]
      end
  end
end
