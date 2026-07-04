# frozen_string_literal: true

class ShipmentsController < ApplicationController
  include ExportsReportable

  before_action :load_shipment, only: %i[edit update destroy invoice packing_slip invoice_iif invoice_csv]
  after_action :skip_policy_scope,
               only: %i[
                 detailed_invoice_report
                 print_detailed_invoice_report
                 total_sales_report
                 print_total_sales_report
                 export_csv export_iif export_pdf invoice_csv
               ]
  decorates_assigned :shipments, :shipment
  helper_method :search_form

  def index
    authorize Shipment
    searched_scope = scope_with_search
    @shipments = searched_scope.paginate(page: params[:page])
    @search_active = search_params.present? && search_params.to_h.values.flatten.any?(&:present?)
    @double_invoices = Shipment.duplicate_invoices(current_bakery, (Time.zone.today - 2.days)..(Time.zone.today + 7.days))
    if @double_invoices.any?
      ActiveRecord::Associations::Preloader.new(
        records: @double_invoices,
        associations: %i[client shipment_items]
      ).call
    end
    @duplicate_invoice_count_in_results = searched_scope.where(id: @double_invoices.map(&:id)).distinct.count
  end

  def product_invoiced_for_year
    authorize Shipment, :index?
    @clients = policy_scope(Client).select { |x| x.price_variants.empty? }
    @shipments = Shipment.where(
      "bakery_id = ? AND client_id in(?) AND date between ? and ? ",
      current_bakery,
      @clients,
      Time.zone.today.beginning_of_year,
      Time.zone.today.end_of_year
    )
    respond_to do |format|
      format.html
      format.xlsx { render xlsx: "product_invoiced_for_year", filename: "yearly_production_total.xlsx" }
    end
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
      render "new", status: :unprocessable_content
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
      render "edit", status: :unprocessable_content
    end
  end

  def destroy
    authorize @shipment
    @shipment.destroy!
    respond_to do |format|
      format.html do
        flash[:notice] = "You have deleted the invoice for #{@shipment.client_name}."
        redirect_to shipments_path, status: :see_other
      end
      format.js
    end
  end

  def invoice
    authorize @shipment, :show?
    generator = InvoicePdfGenerator.new(current_bakery, @shipment)
    create_export_and_respond(generator)
  end

  def detailed_invoice_report
    authorize Shipment, :index?
    @start_date = start_date
    @end_date = end_date
  end

  def print_detailed_invoice_report
    authorize Shipment, :index?
    @start_date = start_date
    @end_date = end_date
    generator = DetailedInvoiceReportGenerator.new(current_bakery, start_date, end_date)
    create_export_and_respond(generator)
  end

  def total_sales_report
    authorize Shipment, :index?
    @start_date = start_date
    @end_date = end_date
  end

  def print_total_sales_report
    authorize Shipment, :index?
    @start_date = start_date
    @end_date = end_date
    generator = TotalSalesGenerator.new(current_bakery, start_date, end_date)
    create_export_and_respond(generator)
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
    create_export_and_respond(generator)
  end

  def export_csv
    authorize Shipment, :index?
    generator = InvoicesCsvGenerator.new(current_bakery, search_form)
    create_export_and_respond(generator)
  end

  def export_iif
    authorize Shipment, :index?
    generator = InvoicesIifGenerator.new(current_bakery, search_form)
    create_export_and_respond(generator)
  end

  def export_pdf
    authorize Shipment, :index?
    generator = InvoicesPdfGenerator.new(current_bakery, search_form)
    create_export_and_respond(generator)
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
    policy_scope(Shipment).search(search_form).includes(:shipment_items, :client)
  end

  def search_params
    params[:search]&.permit(ShipmentSearchForm.params)
  end

  def shipment_params
    params.require(:shipment).permit(
      :alert,
      :client_id, :route_id, :date,
      :discount_type,
      :discount_value,
      :payment_due_date,
      :po_number,
      :delivery_fee, :note,
      shipment_items_attributes: %i[id product_id product_quantity product_price _destroy]
    )
  end

  def date_query
    parsed_date_param(:date)
  end

  def start_date
    parsed_date_param(:start_date)
  end

  def end_date
    parsed_date_param(:end_date, fallback: Time.zone.today + 1.day)
  end
end
