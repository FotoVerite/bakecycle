class OrdersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource except: [:new]
  decorates_assigned :orders, :order

  def index
  end

  def new
    @order = Order.new(order_type: 'standing', start_date: Date.today)
    @order_creator = OrderCreator.new
    @order.order_items.build
  end

  def create
    if @order.save
      flash[:notice] = "You have created a #{@order.order_type} order for #{@order.client.name}."
      redirect_to edit_order_path(@order)
    else
      @order_creator = OrderCreator.new
      render 'new'
    end
  end

  def edit
    @order_creator = OrderCreator.new
  end

  def update
    if @order.update(order_params)
      flash[:notice] = "You have updated the #{@order.order_type} order for #{@order.client.name}."
      redirect_to edit_order_path(@order)
    else
      @order_creator = OrderCreator.new
      render 'edit'
    end
  end

  def destroy
    @order.destroy!
    flash[:notice] = "You have deleted the #{@order.order_type} order for #{@order.client.name}."
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
