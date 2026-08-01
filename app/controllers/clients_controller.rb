# frozen_string_literal: true

class ClientsController < ApplicationController
  include ExportsReportable

  before_action :set_client, only: %i[show edit update destroy]
  before_action :skip_policy_scope, only: %i[
    client_food_cost_report
    print_client_list
    print_total_report
    print_vip_list
    print_weekly_daily_report
    total_report
    weekly_daily_report
  ]
  decorates_assigned :clients, :client

  def index
    authorize Client
    @client_filter = client_filter
    @clients = filtered_clients
      .order_by_name
      .paginate(page: params[:page])
  end

  def new
    @client = policy_scope(Client).build(active: true, billing_term: "net_30")
    authorize @client
  end

  def create
    @client = policy_scope(Client).build(client_params)
    authorize @client
    if @client.save
      flash[:notice] = "You have created #{@client.name}."
      redirect_to client_path(@client)
    else
      render "new", status: :unprocessable_content
    end
  end

  def edit
    authorize @client
  end

  def show
    authorize @client
  end

  def update
    authorize @client
    if @client.update(client_params)
      flash[:notice] = "You have updated #{@client.name}."
      redirect_to client_path(@client)
    else
      render "edit", status: :unprocessable_content
    end
  end

  def destroy
    authorize @client
    @client.destroy!
    flash[:notice] = "You have deleted #{@client.name}"
    redirect_to clients_path, status: :see_other
  end

  def year_total
    authorize Route, :print?
  end

  def total_report
    authorize Route, :print?
    @start_date = start_date
    @end_date = end_date
  end

  def client_food_cost_report
    authorize Route, :print?
    @start_date = start_date
    @end_date = end_date
    @client_ids = filter_param_ids(:client_ids)
    @product_ids = filter_param_ids(:product_ids)

    @available_clients = ItemFinder.new(current_user).clients.order_by_name
    @available_products = ItemFinder.new(current_user).products.order_by_name

    if @client_ids&.size == 1
      @selected_client = @available_clients.find { |client|
        client.id.to_s == @client_ids.first
      }
    end
    if @selected_client && @product_ids&.size == 1
      @selected_product = @available_products.find { |product|
        product.id.to_s == @product_ids.first
      }
    end

    @query = ClientFoodCostQuery.new(current_bakery, @start_date, @end_date,
                                     client_ids: @client_ids, product_ids: @selected_client ? @product_ids : nil)

    # Three drill levels: everyone -> one client's items -> one item's dates.
    # A flat (client, item, date) grid was the first cut and was unusable at
    # scale -- 181 clients open at once, each with 100+ rows. This keeps each
    # screen to what a person actually scans: ~180 client rows, or ~10-30
    # item rows for one client, or ~30 date rows for one item.
    if @selected_client && @selected_product
      @daily_rows = @query.daily_rows
    elsif @selected_client
      @item_totals = @query.item_totals
    else
      @client_summaries = @query.client_summaries
    end
  end

  def print_total_report
    authorize Route, :print?
    @start_date = start_date
    @end_date = end_date
    generator = ClientTotalGenerator.new(current_bakery, start_date, end_date)
    create_export_and_respond(generator)
  end

  def weekly_daily_report
    authorize Client, :index?
    @date = date_query
  end

  def print_client_list
    authorize Client, :index?
    generator = ClientListGenerator.new(current_bakery, params[:type])
    create_export_and_respond(generator)
  end

  def print_weekly_daily_report
    authorize Client, :index?
    @date = date_query
    generator = ClientTotalsGenerator.new(current_bakery, date_query, params[:type])
    create_export_and_respond(generator)
  end

  def print_vip_list
    authorize Client, :index?
    @date = date_query
    generator = VipListGenerator.new(current_bakery)
    create_export_and_respond(generator)
  end

  def set_yearly_clients
    authorize Client, :index?
    @clients = policy_scope(Client)
      .order_by_name
  end

  def yearly_total
    authorize Client, :index?
    ids = params[:client_ids].flatten.reject(&:empty?)
    @clients = policy_scope(Client).find(ids)
    @start_date = (Time.zone.now - 1.year).beginning_of_year
    @end_date = (Time.zone.now - 1.year).end_of_year
    render layout: false
  end

  private

  def date_query
    parsed_date_param(:date)
  end

  def start_date
    parsed_date_param(:start_date)
  end

  def end_date
    parsed_date_param(:end_date, fallback: Time.zone.today + 1.day)
  end

  def filter_param_ids(key)
    Array(params[key]).reject(&:blank?).presence
  end

  def filtered_clients
    scope = policy_scope(Client)
    scope = scope.where(active: @client_filter[:active] == "true") unless @client_filter[:active] == "any"
    scope = scope.where(engagement_status: @client_filter[:status]) unless @client_filter[:status] == "any"
    scope = scope.where(client_name_search_sql, client_name_search_pattern) if @client_filter[:name].present?
    scope
  end

  def client_filter
    permitted = params.fetch(:filter, ActionController::Parameters.new).permit(:name, :status, :active)
    {
      name: permitted[:name].to_s.strip,
      status: client_filter_value(permitted[:status], Client.engagement_statuses.keys, "current"),
      active: client_filter_value(permitted[:active], %w[true false any], "true")
    }
  end

  def client_filter_value(value, allowed_values, default)
    allowed_values.include?(value) ? value : default
  end

  def client_name_search_sql
    "regexp_replace(lower(clients.name), '\\s+', '', 'g') LIKE ?"
  end

  def client_name_search_pattern
    chars = ActiveRecord::Base.sanitize_sql_like(@client_filter[:name].downcase.delete(" ")).chars
    "%#{chars.join('%')}%"
  end

  def set_client
    @client = policy_scope(Client)
      .find(params[:id])
  end

  def client_params
    params.require(:client).permit(
      :active,
      :alert,
      :billing_term,
      :group,
      :channel,
      :default_discount_type,
      :default_discount_value,
      :delivery_fee, :delivery_minimum,
      :delivery_address_street_1, :delivery_address_street_2,
      :delivery_address_city, :delivery_address_state, :delivery_address_zipcode,
      :engagement_status,
      :name, :official_company_name, :ein, :business_phone, :business_fax,
      :billing_address_street_1, :billing_address_street_2, :billing_address_city,
      :billing_address_state, :billing_address_zipcode, :accounts_payable_contact_name,
      :accounts_payable_contact_phone, :accounts_payable_contact_email, :primary_contact_name,
      :primary_contact_phone, :primary_contact_email, :secondary_contact_name,
      :secondary_contact_phone, :secondary_contact_email, :delivery_fee_option,
      :notes, :print_invoice,
      :send_shipment_when_generated,
      :temp_vip, :wholesale_manager
    )
  end
end
