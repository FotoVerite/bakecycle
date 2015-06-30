class RoutesController < ApplicationController
  before_action :authenticate_user!
  before_action :skip_authorization, :skip_policy_scope
  load_and_authorize_resource
  before_action :error_if_remaining_route, only: :destroy
  before_action :error_if_orders, only: :destroy
  decorates_assigned :routes, :route

  def index
    @routes = @routes.order('active desc', :name)
  end

  def new
    @route = Route.new(active: true)
  end

  def create
    if @route.save
      flash[:notice] = "You have created #{@route.name}."
      redirect_to edit_route_path(@route)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @route.update(route_params)
      flash[:notice] = "You have updated #{@route.name}."
      redirect_to edit_route_path(@route)
    else
      render 'edit'
    end
  end

  def destroy
    @route.destroy!
    flash[:notice] = "You have deleted #{@route.name}"
    redirect_to routes_path
  end

  private

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

  def route_params
    params.require(:route).permit(:name, :notes, :departure_time, :active)
  end
end
