class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_search_form, only: [:index, :active_orders]
  before_action :set_order, only: [:edit, :update, :destroy, :copy]
  decorates_assigned :orders, :order

  def index
    authorize Order
    @orders = policy_scope(Order)
      .search(@search_form)
      .sort_for_history
      .paginate(page: params[:page])
  end

  def new
    @order = policy_scope(Order).build(order_type: 'standing', start_date: Time.zone.today)
    @order.route = item_finder.routes.first if item_finder.routes.count == 1
    @order.order_items.build
    authorize @order
  end

  def create
    @order = policy_scope(Order).build(order_params)
    authorize @order
    if @order.save
      flash[:notice] = "You have created a #{@order.order_type} order for #{@order.client_name}."
      redirect_to edit_order_path(@order)
    else
      render 'new'
    end
  end

  def edit
    authorize @order
  end

  def update
    authorize @order
    if @order.update(order_params)
      flash[:notice] = "You have updated the #{@order.order_type} order for #{@order.client_name}."
      redirect_to edit_order_path(@order)
    else
      render 'edit'
    end
  end

  def destroy
    authorize @order
    @order.destroy!
    flash[:notice] = "You have deleted the #{@order.order_type} order for #{@order.client_name}."
    redirect_to orders_path
  end

  def active_orders
    authorize Order, :index?
    active_nav(:active_orders)
    @search_form.date ||= Time.zone.today
    @orders = policy_scope(Order)
      .active(@search_form.date)
      .search(@search_form)
      .sort_for_active
      .paginate(page: params[:page])
  end

  def copy
    @order = OrderDuplicate.new(@order).order_dup
    authorize @order, :create?
    render 'new'
  end

  private

  def set_order
    @order = policy_scope(Order).find(params[:id])
  end

  def load_search_form
    @search_form = OrderSearchForm.new(params[:search])
  end

  def order_params
    params.require(:order).permit(
      :start_date, :end_date, :client_id, :route_id, :note, :order_type,
      order_items_attributes:
      [:id, :product_id, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :_destroy]
    )
  end
end
