require "rails_helper"

RSpec.describe "Clients", type: :request do
  let(:bakery)  { create(:bakery) }
  let(:user)    { create(:user, bakery: bakery) }
  let!(:client) { create(:client, bakery: bakery) }

  # set_client does joins(:shipments), so the client must have at least one.
  before { create(:shipment, bakery: bakery, client: client) }

  describe "unauthenticated" do
    it "redirects to sign in" do
      get clients_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "none permission" do
    before { sign_in create(:user, bakery: bakery, client_permission: "none") }

    it "blocks index" do
      get clients_path
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
      expect(response).to be_redirect
    end

    it "blocks new" do
      get new_client_path
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end
  end

  describe "read permission" do
    before { sign_in create(:user, bakery: bakery, client_permission: "read") }

    it "allows index" do
      get clients_path
      expect(response).to be_successful
    end

    it "allows show" do
      get client_path(client)
      expect(response).to be_successful
    end

    it "blocks new" do
      get new_client_path
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end

    it "blocks create" do
      post clients_path, params: { client: { name: "Denied" } }
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end

    it "blocks edit" do
      get edit_client_path(client)
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end
  end

  describe "manage permission" do
    before { sign_in user }

    it "lists clients" do
      get clients_path
      expect(response).to be_successful
    end

    it "shows a client" do
      get client_path(client)
      expect(response).to be_successful
    end

    it "shows new client form" do
      get new_client_path
      expect(response).to be_successful
    end

    it "creates a client with valid params" do
      params = {
        name: "Wizards Coffee",
        active: true,
        billing_term: "net_30",
        delivery_fee_option: "no_delivery_fee",
        delivery_address_street_1: "123 Main St",
        delivery_address_city: "Brooklyn",
        delivery_address_state: "NY",
        delivery_address_zipcode: "11201",
        accounts_payable_contact_name: "Jane Smith",
        accounts_payable_contact_email: "jane@wizards.com",
        accounts_payable_contact_phone: "555-1234",
      }
      expect { post clients_path, params: { client: params } }.to change(Client, :count).by(1)
      expect(flash[:notice]).to match(/You have created Wizards Coffee/)
    end

    it "shows edit form" do
      get edit_client_path(client)
      expect(response).to be_successful
    end

    it "updates a client" do
      patch client_path(client), params: { client: { name: "Updated Name" } }
      expect(client.reload.name).to eq("Updated Name")
      expect(flash[:notice]).to match(/You have updated/)
    end
  end

  describe "data scoping" do
    before { sign_in user }

    # policy_scope scopes to current bakery at DB level → RecordNotFound, not Pundit error
    it "raises RecordNotFound for another bakery's client" do
      other_bakery = create(:bakery)
      other_client = create(:client, bakery: other_bakery)
      create(:shipment, bakery: other_bakery, client: other_client)
      expect { get client_path(other_client) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
