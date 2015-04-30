class ShipmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_search_form, only: [:index, :invoices, :invoices_csv, :invoices_iif]
  load_and_authorize_resource
  decorates_assigned :shipments, :shipment

  def index
    @shipments = @shipments.search(@search_form).paginate(page: params[:page])
  end

  def new
    @shipment.shipment_items.build
  end

  def invoice
    pdf = InvoicePdf.new(@shipment.decorate, current_bakery)
    pdf_name = "#{current_bakery.name}-#{@shipment.client_name}-#{@shipment.invoice_number}.pdf"
    send_data pdf.render, filename: pdf_name, type: 'application/pdf', disposition: 'inline'
  end

  def packing_slip
    pdf = PackingSlipPdf.new(@shipment.decorate, current_bakery)
    pdf_name = "#{current_bakery.name}-#{@shipment.client_name}-#{@shipment.invoice_number}.pdf"
    send_data pdf.render, filename: pdf_name, type: 'application/pdf', disposition: 'inline'
  end

  def invoices_csv
    @shipments = filtered_shipment_search
    csv_string = InvoicesCsv.new(@shipments.decorate)
    send_data csv_string.generate, filename: 'invoices.csv', type: 'text/csv', disposition: 'attachment'
  end

  def invoices
    @shipments = filtered_shipment_search
    pdf = InvoicesPdf.new(@shipments.decorate, current_bakery)
    pdf_name = 'invoices.pdf'
    send_data pdf.render, filename: pdf_name, type: 'application/pdf', disposition: 'inline'
  end

  def invoice_iif
    iif_string = InvoiceIif.new(@shipment.decorate)
    send_data iif_string.generate, content_type: 'text/plain', filename: 'bakecycle-quickbook-export.iif'
  end

  def invoices_iif
    @shipments = filtered_shipment_search
    iif_string = InvoicesIif.new(@shipments.decorate)
    send_data iif_string.generate, content_type: 'text/plain', filename: 'bakecycle-quickbook-export.iif'
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

  def load_search_form
    @search_form = ShipmentSearchForm.new(search_params)
  end

  def filtered_shipment_search
    @shipments.search(@search_form).includes(:shipment_items, :bakery)
  end

  def search_params
    search = params.permit(:utf8, :page, :format, search: [:client_id, :date_from, :date_to])
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
