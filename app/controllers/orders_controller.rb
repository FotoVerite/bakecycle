class OrdersController < ApplicationController
  before_action :authenticate_user!
  def index
    @orders = Order.all
  end

  def new
    @order = Order.new
    @routes = Route.all
    @clients = Client.all
  end

  def create
    @order = Order.new(order_params)
    if @order.save
      flash[:notice] = "You have created an order for #{@order.client.name}."
      redirect_to edit_order_path(@order)
    else
      @routes = Route.all
      @clients = Client.all
      render 'new'
    end
  end

  def edit
    @order = Order.find(params[:id])
    @routes = Route.all
    @clients = Client.all
  end

  def update
    @order = Order.find(params[:id])
    if @order.update(order_params)
      flash[:notice] = "You have updated the order for #{@order.client.name}."
      redirect_to edit_order_path(@order)
    else
      @routes = Route.all
      @clients = Client.all
      render 'edit'
    end
  end

  def destroy
    Order.destroy(params[:id])
    redirect_to orders_path
  end

  private

  def order_params
    params.require(:order).permit(:start_date, :end_date, :client_id, :route_id, :note)
  end
end
