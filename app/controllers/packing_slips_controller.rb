class PackingSlipsController < ApplicationController
  before_action :skip_policy_scope

  def index
    authorize Route
    @date = date_query
    @shipments = shipments_for(@date)
  end

  def print
    authorize Route, :print?
    generator = PackingSlipsGenerator.new(current_bakery, slip_date, print_invoices?)
    redirect_to ExporterJob.create(current_bakery, generator)
  end

  private

  def shipments_for(date)
    item_finder.shipments.search(date: date).order_by_route_and_client.includes(:shipment_items)
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
