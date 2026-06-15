# frozen_string_literal: true

class CancellationsController < ApplicationController
  before_action :skip_policy_scope

  def new
    authorize Client, :new?
    @date                = parse_date(params[:date]) || Date.tomorrow
    @selected_client_ids = Array(params[:client_ids]).reject(&:blank?).map(&:to_i)
    load_form_data
  end

  def create
    authorize Client, :new?
    @date                = parse_date(params[:date]) || Date.tomorrow
    client_ids           = Array(params[:client_ids]).reject(&:blank?).map(&:to_i)
    @selected_client_ids = client_ids
    load_form_data

    if client_ids.empty?
      flash.now[:alert] = "Please select at least one client."
      return render :new, status: :unprocessable_entity
    end

    assign_cancellation_result(client_ids)
    render :new
  end

  private

  def parse_date(str)
    Date.parse(str) if str.present?
  rescue ArgumentError
    nil
  end

  def load_form_data
    @routes       = current_bakery.routes.where(active: true).order(:name)
    @clients      = current_bakery.clients
                                   .where.not(channel: "Internal")
                                   .where(id: client_ids_with_orders_on(@date))
                                   .order(:name)
    @client_route = build_client_route_map
  end

  def client_ids_with_orders_on(date)
    weekday = date.strftime("%A").downcase

    Order
      .standing(date)
      .where(bakery: current_bakery)
      .joins(:order_items)
      .where(order_items: { removed: 0 })
      .where("order_items.#{weekday} > 0")
      .distinct
      .pluck(:client_id)
  end

  def assign_cancellation_result(client_ids)
    service = OrderCancellationService.new(current_bakery, client_ids, @date)

    if params[:step] == "confirm"
      force_ids = Array(params[:force_client_ids]).reject(&:blank?).map(&:to_i)
      @results  = service.cancel!(force_client_ids: force_ids)
      @step     = "results"
    else
      @preview    = service.preview
      @step       = "preview"
      @client_ids = client_ids
    end
  end

  def build_client_route_map
    Order
      .where(bakery: current_bakery)
      .active_orders
      .where.not(route_id: nil)
      .group(:client_id)
      .pluck(:client_id, Arel.sql("MIN(route_id)"))
      .to_h
  end
end
