class ShipmentsController < ApplicationController
  before_action :load_shipment, only: %i[edit update destroy invoice packing_slip invoice_iif invoice_csv]
  after_action :skip_policy_scope, only: %i[export_csv export_iif export_pdf invoice_csv]
  decorates_assigned :shipments, :shipment
  helper_method :search_form

  def index
    authorize Shipment
    @shipments = scope_with_search.paginate(page: params[:page])
    @double_invoices = Shipment.where('date between ? and ? ',(Date.today -2.days), (Date.today + 3.days)).group_by{ |e| [e.date, e.client_id, e.route_id] }.select { |k, v| v.size > 1 }.values.flatten
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
      render "new"
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
      render "edit"
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
    generator = InvoicePdfGenerator.new(current_bakery, @shipment)
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  def packing_slip
    authorize @shipment, :show?
    pdf = PackingSlipsPdf.new([@shipment], current_bakery)
    pdf_name = "#{current_bakery.name}-#{@shipment.client_name}-#{@shipment.invoice_number}.pdf"
    expires_now
    send_data pdf.render, filename: pdf_name, type: "application/pdf", disposition: "inline"
  end

  def invoice_csv
    authorize @shipment, :show?
    generator = InvoiceCsvGenerator.new(current_bakery, @shipment)
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  def export_csv
    authorize Shipment, :index?
    generator = InvoicesCsvGenerator.new(current_bakery, search_form)
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  def export_iif
    authorize Shipment, :index?
    generator = InvoicesIifGenerator.new(current_bakery, search_form)
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  def export_pdf
    authorize Shipment, :index?
    generator = InvoicesPdfGenerator.new(current_bakery, search_form)
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  def invoice_iif
    authorize @shipment, :show?
    quickbooks_iif = InvoicesIif.new(Shipment.where(id: @shipment))
    expires_now
    send_data quickbooks_iif.generate, content_type: "text/plain", filename: "bakecycle-quickbook-export.iif"
  end

  private

  def load_shipment
    @shipment = policy_scope(Shipment).find(params[:id])
  end

  def search_form
    @_search_form ||= ShipmentSearchForm.new(search_params)
  end

  def scope_with_search
    policy_scope(Shipment).search(search_form).includes(:shipment_items)
  end

  def search_params
    params[:search].permit(ShipmentSearchForm.params) if params[:search]
  end

  def shipment_params
    params.require(:shipment).permit(
      :client_id, :route_id, :date, :payment_due_date, :delivery_fee, :note,
      shipment_items_attributes:
      %i[id product_id product_quantity product_price _destroy]
    )
  end
end
