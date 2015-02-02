class ClientsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource

  def index
    @clients = Client.all.decorate
  end

  def new
    @client = Client.new(active: true, billing_term: "net_30")
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      flash[:notice] = "You have created #{@client.name}."
      redirect_to client_path(@client)
    else
      render 'new'
    end
  end

  def edit
    @client = Client.find(params[:id])
  end

  def show
    @client = Client.find(params[:id]).decorate
    @shipments = Shipment.recent_shipments(@client)
  end

  def update
    @client = Client.find(params[:id])
    if @client.update(client_params)
      flash[:notice] = "You have updated #{@client.name}."
      redirect_to client_path(@client)
    else
      render 'edit'
    end
  end

  def destroy
    Client.destroy(params[:id])
    redirect_to clients_path
  end

  private

  def client_params
    params.require(:client).permit(
      :name, :dba, :business_phone, :business_fax,
      :active, :delivery_address_street_1, :delivery_address_street_2,
      :delivery_address_city, :delivery_address_state, :delivery_address_zipcode,
      :billing_address_street_1, :billing_address_street_2, :billing_address_city,
      :billing_address_state, :billing_address_zipcode, :accounts_payable_contact_name,
      :accounts_payable_contact_phone, :accounts_payable_contact_email, :primary_contact_name,
      :primary_contact_phone, :primary_contact_email, :secondary_contact_name,
      :secondary_contact_phone, :secondary_contact_email, :billing_term)
  end
end
