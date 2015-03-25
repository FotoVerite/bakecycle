class RoutesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
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
    if @route.orders.any?
      flash[:error] = I18n.t :route_in_use, count: @route.orders.count
      return redirect_to edit_route_path(@route)
    end

    @route.destroy!
    flash[:notice] = "You have deleted #{@route.name}"
    redirect_to routes_path
  end

  private

  def route_params
    params.require(:route).permit(:name, :notes, :departure_time, :active)
  end
end
