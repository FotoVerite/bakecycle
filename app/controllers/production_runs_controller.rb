class ProductionRunsController < ApplicationController
  before_action :set_production_run, only: %i[edit update print reset]
  after_action :skip_policy_scope, only: %i[
    print_projection
    print_recipes
    print_test_projection
    print_weekly_daily_production_report
    weekly_daily_production_report
    date_span_production_report
    print_date_span_production_report
  ]
  decorates_assigned :production_runs, :production_run

  def index
    authorize ProductionRun
    @date = index_date_query
    @production_runs = production_runs_index_scope
      .order(date: :desc)
      .paginate(page: params[:page])
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

  def date_span_production_report
    authorize ProductionRun, :can_print?
    @start_date = start_date
    @end_date = end_date
  end

  def print_date_span_production_report
    authorize ProductionRun, :can_print?
    @start_date = start_date
    @end_date = end_date
    generator = DateSpanProductionRunTotalsGenerator.new(current_bakery, start_date, end_date)
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

  def test_projection
    authorize ProductionRun, :can_print?
    @production_run = policy_scope(ProductionRun).build
  end

  def print_test_projection
    authorize ProductionRun, :can_print?
    order_items = params[:production_run][:run_items_attributes].permit!.to_h.map do |o|
      "#{o[1]['product_id']}:#{o[1]['overbake_quantity']}"
    end
    generator = TestProjectionGenerator.new(current_bakery, Time.zone.today, order_items)
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
    parsed_date_param(:date)
  end

  def index_date_query
    optional_parsed_date_param(:date)
  end

  def production_runs_index_scope
    scope = policy_scope(ProductionRun)
    return scope unless @date

    scope.for_date(@date)
  end

  def start_date
    parsed_date_param(:start_date, fallback: Time.zone.today.beginning_of_year)
  end

  def end_date
    parsed_date_param(:end_date)
  end

  def production_run_for_date(date)
    item_finder
      .production_runs
      .for_date(date)
      .first
  end
end
