class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_search_form, only: [:index, :active_orders]
  before_action :skip_authorization, :skip_policy_scope
  load_and_authorize_resource
  decorates_assigned :orders, :order

  def index
    @orders = @orders
      .search(@search_form)
      .sort_for_history
      .paginate(page: params[:page])
  end

  def active_orders
    active_nav(:active_orders)
    @search_form.date ||= Time.zone.today
    @orders = @orders
      .active(@search_form.date)
      .search(@search_form)
      .sort_for_active
      .paginate(page: params[:page])
  end

  def copy
    @order = OrderDuplicate.new(@order).order_dup
    render 'new'
  end

  def new
    @order.assign_attributes(order_type: 'standing', start_date: Time.zone.today)
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
  end

  def update
    if @order.update(order_params)
      flash[:notice] = "You have updated the #{@order.order_type} order for #{@order.client_name}."
      redirect_to edit_order_path(@order)
    else
      render 'edit'
    end
  end

  def destroy
    @order.destroy!
    flash[:notice] = "You have deleted the #{@order.order_type} order for #{@order.client_name}."
    redirect_to orders_path
  end

  private

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
