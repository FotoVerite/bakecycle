class ShipmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @search_form = ShipmentSearchForm.new(search_params)
    @shipments = Shipment.search(@search_form.to_h)
    @order_creator = OrderCreator.new
  end

  def new
    @shipment = Shipment.new
    @order_creator = OrderCreator.new
  end

  def create
    @shipment = Shipment.new(shipment_params)
    if @shipment.save
      flash[:notice] = "You have created a shipment for #{@shipment.client.name}."
      redirect_to edit_shipment_path(@shipment)
    else
      @order_creator = OrderCreator.new
      render 'new'
    end
  end

  def edit
    @shipment = Shipment.find(params[:id])
    @order_creator = OrderCreator.new
  end

  def update
    @shipment = Shipment.find(params[:id])
    if @shipment.update(shipment_params)
      flash[:notice] = "You have updated the shipment for #{@shipment.client.name}."
      redirect_to edit_shipment_path(@shipment)
    else
      @order_creator = OrderCreator.new
      render 'edit'
    end
  end

  def destroy
    Shipment.destroy(params[:id])
    redirect_to shipments_path
  end

  private

  def search_params
    search = params.permit(:utf8, search: [:client_id, :date_from, :date_to])
    search[:search]
  end

  def shipment_params
    params.require(:shipment).permit(
      :client_id, :route_id, :date, :payment_due_date,
      shipment_items_attributes:
      [:id, :product_id, :product_quantity, :price_per_item, :_destroy]
    )
  end
end
