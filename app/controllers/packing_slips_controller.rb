# frozen_string_literal: true

class PackingSlipsController < ApplicationController
  include ExportsReportable

  before_action :skip_policy_scope

  def index
    authorize Route
    @date = date_query
    @shipments = shipments_for(@date)
  end

  def print
    authorize Route, :print?
    generator = PackingSlipsGenerator.new(current_bakery, slip_date, print_invoices?)
    create_export_and_respond(generator)
  end

  def print_list
    authorize Route, :print?
    generator = PackListGenerator.new(current_bakery, slip_date)
    create_export_and_respond(generator)
  end

  def print_sorted_list
    authorize Route, :print?
    generator = SortedPackListGenerator.new(current_bakery, slip_date)
    create_export_and_respond(generator)
  end

  private

  def shipments_for(date)
    item_finder.shipments.search(date: date).order_by_route_and_client
  end

  def date_query
    parsed_date_param(:date)
  end

  def slip_date
    parsed_date_param(:date)
  end

  def print_invoices?
    params[:print][:include_invoices] == "1"
  end
end
