class ClientsController < ApplicationController
  before_action :set_client, only: %i[show edit update destroy]
  before_action :skip_policy_scope, only: %i[
    print_client_list
    print_total_report
    print_vip_list
    print_weekly_daily_report
    print_year_total
    total_report
    weekly_daily_report
  ]
  decorates_assigned :clients, :client

  def index
    authorize Client
    @clients = policy_scope(Client)
      .order_by_name
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
      render "new"
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
      render "edit"
    end
  end

  def destroy
    authorize @client
    @client.destroy!
    flash[:notice] = "You have deleted #{@client.name}"
    redirect_to clients_path
  end

  def year_total
    authorize Route, :print?
  end

  def total_report
    authorize Route, :print?
    @start_date = start_date
    @end_date = end_date
  end

  def print_total_report
    authorize Route, :print?
    @start_date = start_date
    @end_date = end_date
    generator = ClientTotalGenerator.new(current_bakery, start_date, end_date)
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  def weekly_daily_report
    authorize Client, :index?
    @date = date_query
  end

  def print_client_list
    authorize Client, :index?
    generator = ClientListGenerator.new(current_bakery, params[:type])
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  def print_weekly_daily_report
    authorize Client, :index?
    @date = date_query
    generator = ClientTotalsGenerator.new(current_bakery, date_query, params[:type])
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  def print_vip_list
    authorize Client, :index?
    @date = date_query
    generator = VipListGenerator.new(current_bakery)
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  def set_yearly_clients
    authorize Client, :index?
    @clients = policy_scope(Client)
      .order_by_name
  end

  def yearly_total
    authorize Client, :index?
    ids = params[:client_ids].flatten.reject { |x| x.empty? }
    @clients = policy_scope(Client).find(ids)
    @start_date = (Time.now - 1.year).beginning_of_year
    @end_date = (Time.now - 1.year).end_of_year
    render :layout => false
  end

  private

  def date_query
    Chronic.parse(params[:date]) || Time.zone.today
  end

  def start_date
    Chronic.parse(params[:start_date]) || Time.zone.today
  end

  def end_date
    Chronic.parse(params[:end_date]) || Time.zone.today + 1.days
  end

  def set_client
    @client = policy_scope(Client)
      .joins(:shipments)
      .includes(:shipments)
      .find(params[:id])
  end

  def client_params
    params.require(:client).permit(
      :active,
      :alert,
      :billing_term,
      :group,
      :channel,
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
