class PackingSlipsController < ApplicationController
  before_action :authenticate_user!

  def index
    @date = date_query
    @shipments = shipments_for(date_query)
  end

  def print
    pdf = PackingSlipsPdf.new(shipments_for(slip_date), current_bakery, print_invoices?)
    pdf_name = "packing_slips_#{slip_date}.pdf"
    send_data pdf.render, filename: pdf_name, type: 'application/pdf', disposition: 'inline'
  end

  private

  def shipments_for(date)
    item_finder.shipments.search_by_date(date).order_by_route_and_client.includes(:shipment_items)
  end

  def date_query
    Chronic.parse(params[:date] || Time.zone.today)
  end

  def slip_date
    Chronic.parse(params[:print][:date])
  end

  def print_invoices?
    params[:print][:include_invoices] == '1'
  end
end
