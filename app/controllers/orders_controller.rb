class OrdersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  decorates_assigned :orders, :order

  def index
    # client_dba, route_time ASC, order_startdate
    @orders = @orders.includes(:client, :route).order('start_date desc').paginate(page: params[:page])
  end

  def new
    @order = Order.new(order_type: 'standing', start_date: Time.zone.today)
    @order.route = item_finder.routes.first if item_finder.routes.count == 1
    @order.order_items.build
  end

  def create
    if @order.save
      flash[:notice] = "You have created a #{@order.order_type} order for #{@order.client_name}."
      redirect_to edit_order_path(@order)
    else
      render 'new'
    end
  end

  def edit
    @shipments = Shipment.upcoming(@order)
  end

  def update
    if @order.update(order_params)
      flash[:notice] = "You have updated the #{@order.order_type} order for #{@order.client_name}."
      redirect_to edit_order_path(@order)
    else
      @shipments = Shipment.upcoming(@order)
      render 'edit'
    end
  end

  def destroy
    @order.destroy!
    flash[:notice] = "You have deleted the #{@order.order_type} order for #{@order.client_name}."
    redirect_to orders_path
  end

  private

  def order_params
    params.require(:order).permit(
      :start_date, :end_date, :client_id, :route_id, :note, :order_type,
      order_items_attributes:
      [:id, :product_id, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :_destroy]
    )
  end
end
