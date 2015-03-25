class RoutesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource except: [:new]
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

  def route_params
    params.require(:route).permit(:name, :notes, :departure_time, :active)
  end
end
