class ProductionRunsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @production_runs = item_finder.production_runs
  end

  def edit
    @products = item_finder.products
  end

  def update
    if @production_run.update(production_run_params)
      redirect_to edit_production_run_path(@production_run), notice: 'Successfully updated'
    else
      render :edit
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
end
