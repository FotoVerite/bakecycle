class ProductionRunsController < ApplicationController
  before_action :set_production_run, only: %i[edit update print reset]
  after_action :skip_policy_scope, only: %i[
    print_projection
    print_recipes
    print_weekly_daily_production_report
    weekly_daily_production_report
  ]
  decorates_assigned :production_runs, :production_run

  def index
    authorize ProductionRun
    @production_runs = policy_scope(ProductionRun)
      .order(date: :desc).paginate(page: params[:page])
  end

  def edit
    authorize @production_run
    @missing_items = current_bakery.shipment_items.where(production_start: @production_run.date, production_run_id: nil)
  end

  def update
    authorize @production_run
    if @production_run.update(production_run_params)
      redirect_to edit_production_run_path(@production_run), notice: "Successfully updated"
    else
      render :edit
    end
  end

  def print
    authorize @production_run
    generator = ProductionRunGenerator.new(@production_run)
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  def reset
    authorize @production_run
    ProductionRunService.new(@production_run.bakery, @production_run.date).run
    redirect_to edit_production_run_path(@production_run), notice: "Reset Complete"
  end

  def weekly_daily_production_report
    authorize ProductionRun, :can_print?
    @date = date_query
  end

  def print_weekly_daily_production_report
    authorize ProductionRun, :can_print?
    @date = date_query
    generator = ProductionRunTotalsGenerator.new(current_bakery, date_query, params[:type])
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  def print_recipes
    authorize ProductionRun, :can_print?
    active_nav(:print_recipes)
    @date = date_query
    @production_run = production_run_for_date(@date)
    @projection = ProductionRunProjection.new(current_bakery, @date) unless @production_run
  end

  def print_projection
    authorize ProductionRun, :can_print?
    generator = ProjectionGenerator.new(current_bakery, date_query)
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  private

  def set_production_run
    @production_run = policy_scope(ProductionRun).find(params[:id])
  end

  def production_run_params
    params.require(:production_run).permit(
      :bakery, :end_date, :client_id, :route_id, :note, :order_type,
      run_items_attributes:
      %i[id product_id production_run_id order_quantity overbake_quantity total_quantity _destroy]
    )
  end

  def date_query
    Chronic.parse(params[:date]) || Time.zone.today
  end

  def production_run_for_date(date)
    item_finder
      .production_runs
      .for_date(date)
      .first
  end
end
