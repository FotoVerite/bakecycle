class RoutesController < ApplicationController
  before_action :authenticate_user!
  def index
    @routes = Route.all
  end

  def new
    @route = Route.new
  end

  def create
    @route = Route.new(route_params)

    if @route.save
      flash[:notice] = "You have created #{@route.name}."
      redirect_to edit_route_path(@route)
    else
      render 'new'
    end
  end

  def edit
    @route = Route.find(params[:id])
  end

  def update
    @route = Route.find(params[:id])
    if @route.update(route_params)
      flash[:notice] = "You have updated #{@route.name}."
      redirect_to edit_route_path(@route)
    else
      render 'edit'
    end
  end

  def destroy
    Route.destroy(params[:id])
    redirect_to routes_path
  end

  private

  def route_params
    params.require(:route).permit(:name, :notes, :departure_time, :active)
  end
end
