class ClientsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  decorates_assigned :clients, :client

  def index
    @clients = @clients.order(:name)
  end

  def new
    @client = Client.new(active: true, billing_term: 'net_30')
  end

  def create
    if @client.save
      flash[:notice] = "You have created #{@client.name}."
      redirect_to client_path(@client)
    else
      render 'new'
    end
  end

  def edit
  end

  def show
    @shipments = item_finder.shipments.recent(@client).includes(:shipment_items)
    @orders =  item_finder.orders
      .where(client: @client)
      .upcoming(Time.zone.now).decorate
  end

  def update
    if @client.update(client_params)
      flash[:notice] = "You have updated #{@client.name}."
      redirect_to client_path(@client)
    else
      render 'edit'
    end
  end

  def destroy
    @client.destroy!
    flash[:notice] = "You have deleted #{@client.name}"
    redirect_to clients_path
  end

  private

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
      :delivery_fee, :delivery_minimum)
  end
end
