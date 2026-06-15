# frozen_string_literal: true

class NightlySignOffsController < ApplicationController
  before_action :skip_authorization
  before_action :skip_policy_scope

  def show
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.tomorrow
    shipments = fetch_shipments

    @total_invoices       = shipments.size
    @blue_bottle          = shipments.select { |s| blue_bottle?(s.client_name) }
    @wholesale_sandwiches = shipments.select { |s| wholesale_sandwiches?(s) }

    excluded_ids = (@blue_bottle + @wholesale_sandwiches).map(&:id).to_set
    @all_clients = shipments.reject { |s| excluded_ids.include?(s.id) }
  end

  private

  def fetch_shipments
    Shipment
      .where(bakery: current_bakery, date: @date)
      .joins(:client)
      .where.not(clients: { channel: "Internal" })
      .includes(:shipment_items)
      .order(:client_name)
      .to_a
  end

  def blue_bottle?(name) = name.downcase.include?("blue bottle")

  def wholesale_sandwiches?(shipment)
    shipment.shipment_items.any? { |item| item.product_product_type == "wholesale_sandwiches" }
  end
end
