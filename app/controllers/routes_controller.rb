class RoutesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_route, only: [:edit, :update, :destroy]
  before_action :error_if_remaining_route, only: :destroy
  before_action :error_if_orders, only: :destroy
  decorates_assigned :routes, :route

  def index
    authorize Route
    @routes = policy_scope(Route).order('active desc', :name)
  end

  def new
    @route = policy_scope(Route).build(active: true)
    authorize @route
  end

  def create
    @route = policy_scope(Route).build(route_params)
    authorize @route
    if @route.save
      flash[:notice] = "You have created #{@route.name}."
      redirect_to edit_route_path(@route)
    else
      render 'new'
    end
  end

  def edit
    authorize @route
  end

  def update
    authorize @route
    if @route.update(route_params)
      flash[:notice] = "You have updated #{@route.name}."
      redirect_to edit_route_path(@route)
    else
      render 'edit'
    end
  end

  def destroy
    authorize @route
    @route.destroy!
    flash[:notice] = "You have deleted #{@route.name}"
    redirect_to routes_path
  end

  private

  def set_route
    @route = policy_scope(Route).find(params[:id])
  end

  def route_params
    params.require(:route).permit(:name, :notes, :departure_time, :active)
  end

  def last_remaining_route?
    item_finder.routes.count == 1
  end

  def error_if_remaining_route
    return false unless last_remaining_route?
    flash[:error] = 'Cannot delete last remaining route'
    redirect_to edit_route_path(@route)
  end

  def error_if_orders
    return false unless @route.orders.any?
    flash[:error] = I18n.t :route_in_use, count: @route.orders.count
    redirect_to edit_route_path(@route)
  end
end
