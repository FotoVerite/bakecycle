class ShipmentsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  decorates_assigned :shipments, :shipment

  def index
    @search_form = ShipmentSearchForm.new(search_params)
    @shipments = @shipments.search(@search_form).paginate(page: params[:page])
  end

  def new
    @shipment.shipment_items.build
  end

  def show
    pdf = InvoicePdf.new(@shipment.decorate)
    pdf_name = "#{current_bakery.name}-#{@shipment.client_name}-#{@shipment.invoice_number}.pdf"
    send_data pdf.render, filename: pdf_name, type: "application/pdf", disposition: "inline"
  end

  def invoices
    search_form = ShipmentSearchForm.new(search_params)
    @shipments = @shipments.search(search_form).includes(:shipment_items, :bakery)
    pdf = InvoicesPdf.new(@shipments.decorate)
    pdf_name = "invoices.pdf"
    send_data pdf.render, filename: pdf_name, type: "application/pdf", disposition: "inline"
  end

  def create
    if @shipment.save
      flash[:notice] = "You have created a shipment for #{@shipment.client_name}."
      redirect_to edit_shipment_path(@shipment)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @shipment.update(shipment_params)
      flash[:notice] = "You have updated the shipment for #{@shipment.client_name}."
      redirect_to edit_shipment_path(@shipment)
    else
      render 'edit'
    end
  end

  def destroy
    @shipment.destroy!
    flash[:notice] = "You have deleted the shipment for #{@shipment.client_name}."
    redirect_to shipments_path
  end

  private

  def search_params
    search = params.permit(:utf8, :page, search: [:client_id, :date_from, :date_to])
    search[:search]
  end

  def shipment_params
    params.require(:shipment).permit(
      :client_id, :route_id, :date, :payment_due_date, :delivery_fee, :note,
      shipment_items_attributes:
      [:id, :product_id, :product_quantity, :product_price, :_destroy]
    )
  end
end
