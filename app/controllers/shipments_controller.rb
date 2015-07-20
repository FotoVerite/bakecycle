class ShipmentsController < ApplicationController
  before_action :set_search_form, only: [:index, :invoices, :invoices_csv, :invoices_iif]
  before_action :set_shipment, only: [:edit, :update, :destroy, :invoice, :packing_slip, :invoice_iif]
  decorates_assigned :shipments, :shipment

  def index
    authorize Shipment
    @shipments = scope_with_search.paginate(page: params[:page])
  end

  def new
    @shipment = policy_scope(Shipment).build
    authorize @shipment
  end

  def create
    @shipment = policy_scope(Shipment).build(shipment_params)
    authorize @shipment
    if @shipment.save
      flash[:notice] = "You have created an invoice for #{@shipment.client_name}."
      redirect_to edit_shipment_path(@shipment)
    else
      render 'new'
    end
  end

  def edit
    authorize @shipment
  end

  def update
    authorize @shipment
    if @shipment.update(shipment_params)
      flash[:notice] = "You have updated the invoice for #{@shipment.client_name}."
      redirect_to edit_shipment_path(@shipment)
    else
      render 'edit'
    end
  end

  def destroy
    authorize @shipment
    @shipment.destroy!
    flash[:notice] = "You have deleted the invoice for #{@shipment.client_name}."
    redirect_to shipments_path
  end

  def invoice
    authorize @shipment, :show?
    pdf = InvoicesPdf.new([@shipment], current_bakery)
    pdf_name = "#{current_bakery.name}-#{@shipment.client_name}-#{@shipment.invoice_number}.pdf"
    expires_now
    send_data pdf.render, filename: pdf_name, type: 'application/pdf', disposition: 'inline'
  end

  def packing_slip
    authorize @shipment, :show?
    pdf = PackingSlipsPdf.new([@shipment], current_bakery)
    pdf_name = "#{current_bakery.name}-#{@shipment.client_name}-#{@shipment.invoice_number}.pdf"
    expires_now
    send_data pdf.render, filename: pdf_name, type: 'application/pdf', disposition: 'inline'
  end

  def invoices_csv
    authorize Shipment, :index?
    @shipments = scope_with_search
    csv_string = InvoicesCsv.new(@shipments.decorate)
    expires_now
    send_data csv_string.generate, filename: 'invoices.csv', type: 'text/csv', disposition: 'attachment'
  end

  def invoices
    authorize Shipment, :index?
    @shipments = scope_with_search
    pdf = InvoicesPdf.new(@shipments.decorate, current_bakery)
    pdf_name = 'invoices.pdf'
    expires_now
    send_data pdf.render, filename: pdf_name, type: 'application/pdf', disposition: 'inline'
  end

  def invoice_iif
    authorize @shipment, :show?
    quickbooks_iif = InvoiceIif.new(@shipment.decorate)
    expires_now
    send_data quickbooks_iif.generate, content_type: 'text/plain', filename: 'bakecycle-quickbook-export.iif'
  end

  def invoices_iif
    authorize Shipment, :index?
    @shipments = scope_with_search
    quickbooks_iif = InvoicesIif.new(@shipments.decorate, current_bakery.decorate)
    expires_now
    send_data quickbooks_iif.generate, content_type: 'text/plain', filename: quickbooks_iif.filename
  end

  private

  def set_shipment
    @shipment = policy_scope(Shipment).find(params[:id])
  end

  def set_search_form
    @search_form = ShipmentSearchForm.new(search_params)
  end

  def scope_with_search
    policy_scope(Shipment).search(@search_form).includes(:shipment_items)
  end

  def search_params
    params[:search].permit(ShipmentSearchForm.params) if params[:search]
  end

  def shipment_params
    params.require(:shipment).permit(
      :client_id, :route_id, :date, :payment_due_date, :delivery_fee, :note,
      shipment_items_attributes:
      [:id, :product_id, :product_quantity, :product_price, :_destroy]
    )
  end
end
