class ProductionRunsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  decorates_assigned :production_runs, :production_run

  def index
    @production_runs = @production_runs.order(date: :desc).paginate(page: params[:page])
  end

  def edit; end

  def update
    if @production_run.update(production_run_params)
      redirect_to edit_production_run_path(@production_run), notice: 'Successfully updated'
    else
      render :edit
    end
  end

  def print_recipes
    active_nav(:print_recipes)
    @date = date_query
    @production_run = production_run_for_date(@date)
    @production_run_projection = ProductionRunProjection.new(current_bakery, @date) unless @production_run
  end

  def batch_recipes
    active_nav(:batch_recipes)
    @start_date = start_date
    @end_date = end_date
    @production_run_projection = ProductionRunProjection.new(current_bakery, @start_date, @end_date)
  end

  def print
    production_run_data = ProductionRunData.new(@production_run)
    pdf = ProductionRunPdf.new(production_run_data)
    expires_now
    send_data pdf.render, filename: 'ProductionRunRecipe.pdf', type: 'application/pdf', disposition: 'inline'
  end

  def print_projection
    projection = ProductionRunProjection.new(current_bakery, date_query)
    projection_run_data = ProjectionRunData.new(projection)

    pdf = ProductionRunPdf.new(projection_run_data)
    expires_now
    send_data pdf.render, filename: 'ProjectionRunRecipe.pdf', type: 'application/pdf', disposition: 'inline'
  end

  def print_batch
    projection = ProductionRunProjection.new(current_bakery, start_date, end_date)
    projection_run_data = ProjectionRunData.new(projection)

    pdf = BatchRunPdf.new(projection_run_data)
    expires_now
    send_data pdf.render, filename: 'BatchRecipes.pdf', type: 'application/pdf', disposition: 'inline'
  end

  def reset
    ProductionRunService.new(@production_run.bakery, @production_run.date).run
    redirect_to edit_production_run_path(@production_run), notice: 'Reset Complete'
  end

  private

  def production_run_params
    params.require(:production_run).permit(
      :bakery, :end_date, :client_id, :route_id, :note, :order_type,
      run_items_attributes:
      [:id, :product_id, :production_run_id, :order_quantity, :overbake_quantity, :total_quantity, :_destroy]
    )
  end

  def date_query
    Chronic.parse(params[:date]) || Time.zone.today
  end

  def start_date
    Chronic.parse(params[:start_date]) || Time.zone.today
  end

  def end_date
    Chronic.parse(params[:end_date]) || Time.zone.today + 6.days
  end

  def production_run_for_date(date)
    item_finder
      .production_runs
      .for_date(date)
      .first
  end
end
