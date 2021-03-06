class OrdersController < ApplicationController
  before_action :set_order, only: %i[
    add_invoices
    copy
    destroy
    edit
    future_invoices
    print
    papertrail
    update
  ]
  decorates_assigned :orders, :order
  helper_method :search_form

  def index
    authorize Order
    @orders = policy_scope(Order)
      .search(search_form)
      .includes(:client, :route)
      .order_by_active
      .paginate(page: params[:page])
    @missing_shipments = policy_scope(Order).production_date(Time.zone.today)
      .search(search_form)
      .reject(&:no_outstanding_shipments?)
  end

  def created_at
    authorize Order
    @date = date_query
    @orders = policy_scope(Order)
      .created_at_date(@date)
      .paginate(page: params[:page])
  end

  def new
    @order = policy_scope(Order).build(client: client, order_type: "standing", start_date: Time.zone.today)
    @order.route = item_finder.routes.first if item_finder.routes.count == 1
    authorize @order
  end

  def create
    @order = policy_scope(Order).build(order_params)
    @order.created_by_user = current_user
    authorize @order
    order_creator = OrderCreator.new(@order, params[:confirm_override])
    if order_creator.run
      redirect_to edit_order_path(@order, updated: order_creator.updated_id), notice: order_creator.success_message
    else
      @order.order_items.each { |item| item.order = @order }
      render "new"
    end
  end

  def edit
    authorize @order
    @updated = Order.find_by(id: params[:updated])
  end

  def updated_at
    authorize Order
    @date = date_query
    @orders = policy_scope(Order)
      .updated_at_date(@date)
      .paginate(page: params[:page])
  end

  def update
    authorize @order
    @order.last_updated_by_user = current_user
    @order.increment(:version_number)
    if @order.update(order_params)
      flash[:notice] = "You have updated the #{@order.order_type} order for #{@order.client_name}."
      redirect_to edit_order_path(@order)
    else
      render "edit"
    end
  end

  def destroy
    authorize @order
    @order.destroy!
    flash[:notice] = "You have deleted the #{@order.order_type} order for #{@order.client_name}."
    redirect_to orders_path
  end

  def future_invoices
    authorize @order, :edit?
    @date = get_date
    Chronic.parse @date
  end

  def add_invoices
    authorize @order, :edit?

    if params[:date]
      dates = get_date..Date.parse(params[:date])
    else
      dates = @order.missing_shipment_dates
    end

    dates.each do |ship_date|
      ShipmentCreator.new(@order, ship_date).create!
    end
    redirect_to edit_order_path(@order)
  end

  def papertrail
    authorize @order, :show?
  end

  def copy
    @order = OrderDuplicate.new(@order).duplicate
    authorize @order, :new?
    render "new"
  end

  def print
    authorize @order, :show?
    generator = OrderGenerator.new(@order)
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  private

  def set_order
    @order = policy_scope(Order).find(params[:id])
  end

  def search_form
    @_search_form ||= OrderSearchForm.new(search_params)
  end

  def client
    @client = Client.find(params[:client_id]) if params[:client_id]
  end

  def search_params
    params[:search].permit(OrderSearchForm.params) if params[:search]
  end

  def order_params
    params.require(:order).permit(
      :alert,
      :start_date, :end_date, :client_id, :route_id, :note, :order_type,
      order_items_attributes:
        %i[id product_id monday tuesday wednesday
           thursday friday saturday sunday _destroy]
    )
  end

  def date_query
    Chronic.parse(params[:date] || params[:id]) || Time.zone.today
  end

  def get_date
    if !@order.shipments.empty?
      @order.shipments.last.date + 1.day
    else
      Time.zone.today + 1.day
    end
  end
end
