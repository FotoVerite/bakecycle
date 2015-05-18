class PackingSlipsController < ApplicationController
  before_action :authenticate_user!

  def index
    @date = date_query
    @shipments = shipments_for_date
  end

  def print
    pdf = PackingSlipsPdf.new(shipments_for_date, current_bakery, print_invoices?)
    pdf_name = "packing_slips_#{params[:date]}.pdf"
    send_data pdf.render, filename: pdf_name, type: 'application/pdf', disposition: 'inline'
  end

  private

  def shipments_for_date
    item_finder.shipments.search_by_date(date_query).order_by_route_and_client.includes(:shipment_items)
  end

  def date_query
    Chronic.parse(params[:date] || Time.zone.today)
  end

  def print_invoices?
    params[:print][:include_invoices] == '1'
  end
end
