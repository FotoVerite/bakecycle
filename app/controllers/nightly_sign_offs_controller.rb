# frozen_string_literal: true

class NightlySignOffsController < ApplicationController
  before_action :skip_authorization
  before_action :skip_policy_scope

  def show
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.tomorrow
    shipments = Shipment
      .where(bakery: current_bakery, date: @date)
      .joins(:client)
      .where.not(clients: { channel: "Internal" })
      .includes(:shipment_items)
      .order(:client_name)
      .to_a
    @total_invoices       = shipments.size
    @blue_bottle          = shipments.select { |s| blue_bottle?(s.client_name) }
    @wholesale_sandwiches = shipments.select { |s| s.shipment_items.any? { |i| i.product_product_type == "wholesale_sandwiches" } }
    excluded_ids          = (@blue_bottle + @wholesale_sandwiches).map(&:id).to_set
    @all_clients          = shipments.reject { |s| excluded_ids.include?(s.id) }
  end

  private

  def blue_bottle?(name) = name.downcase.include?("blue bottle")
end
