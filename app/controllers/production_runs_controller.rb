class ProductionRunsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  decorates_assigned :production_runs, :production_run

  def index
    @production_runs = @production_runs.order(date: :desc).paginate(page: params[:page])
  end

  def print
    production_run_data = ProductionRunData.new(@production_run)
    pdf = ProductionRunPdf.new(production_run_data)
    pdf_name = 'ProductionRunRecipe.pdf'
    send_data pdf.render, filename: pdf_name, type: 'application/pdf', disposition: 'inline'
  end

  def edit; end

  def print_recipes
    active_nav(:print_recipes)
    @date = date_query
    @production_run = item_finder
      .production_runs
      .for_date(@date)
      .first
  end

  def update
    if @production_run.update(production_run_params)
      redirect_to edit_production_run_path(@production_run), notice: 'Successfully updated'
    else
      render :edit, notice: 'Remove duplicate products if applicable'
    end
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
end
