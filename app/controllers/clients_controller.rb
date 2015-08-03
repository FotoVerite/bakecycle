class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]
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
    @shipments = item_finder.shipments.recent(@client).includes(:shipment_items)
    @orders =  item_finder.orders
      .where(client: @client)
      .upcoming(Time.zone.now).decorate
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

  private

  def set_client
    @client = policy_scope(Client).find(params[:id])
  end

  def client_params
    params.require(:client).permit(
      :name, :official_company_name, :ein, :business_phone, :business_fax,
      :active, :delivery_address_street_1, :delivery_address_street_2,
      :delivery_address_city, :delivery_address_state, :delivery_address_zipcode,
      :billing_address_street_1, :billing_address_street_2, :billing_address_city,
      :billing_address_state, :billing_address_zipcode, :accounts_payable_contact_name,
      :accounts_payable_contact_phone, :accounts_payable_contact_email, :primary_contact_name,
      :primary_contact_phone, :primary_contact_email, :secondary_contact_name,
      :secondary_contact_phone, :secondary_contact_email, :billing_term, :delivery_fee_option,
      :delivery_fee, :delivery_minimum, :notes)
  end
end
