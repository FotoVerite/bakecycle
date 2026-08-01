# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Clients", type: :request do
  let(:bakery)  { create(:bakery) }
  let(:user)    { create(:user, bakery: bakery) }
  let!(:client) { create(:client, bakery: bakery) }

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
      expect(response.body).to include('turbo-frame id="clients"')
      expect(response.body).to include("Find clients by name, status, or active account state.")
      expect(response.body).to include("No clients match these filters")
      expect(response.body).to include("Reset filters")
    end

    it "defaults to active current clients" do
      current_client = create(:client, bakery: bakery, name: "Active Current Cafe", active: true,
                                       engagement_status: "current")
      inactive_client = create(:client, bakery: bakery, name: "Inactive Current Cafe", active: false,
                                        engagement_status: "current")
      lapsed_client = create(:client, bakery: bakery, name: "Active Lapsed Cafe", active: true,
                                      engagement_status: "lapsed")

      get clients_path

      expect(response.body).to include(current_client.name)
      expect(response.body).not_to include(inactive_client.name)
      expect(response.body).not_to include(lapsed_client.name)
    end

    it "filters clients on the server" do
      matching_client = create(:client, bakery: bakery, name: "Broad Street Market", active: false,
                                        engagement_status: "lapsed")
      create(:client, bakery: bakery, name: "Broad Street Current", active: true, engagement_status: "current")
      create(:client, bakery: bakery, name: "Another Lapsed Client", active: false, engagement_status: "lapsed")

      get clients_path, params: { filter: { name: "brd", status: "lapsed", active: "false" } }

      expect(response.body).to include(matching_client.name)
      expect(response.body).not_to include("Broad Street Current")
      expect(response.body).not_to include("Another Lapsed Client")
    end

    it "paginates the rendered client rows" do
      original_per_page = Client.per_page
      Client.per_page = 2
      create_list(:client, 3, bakery: bakery, active: true, engagement_status: "current")

      get clients_path

      expect(response.body.scan(/data-filter-table-target="row"/).count).to eq(2)
    ensure
      Client.per_page = original_per_page
    end

    it "shows a client" do
      get client_path(client)
      expect(response).to be_successful
    end

    it "shows a delivery location map when coordinates are present" do
      client.update!(latitude: 40.7143528, longitude: -74.0059731)

      get client_path(client)

      document = Nokogiri::HTML(response.body)
      map_frame = document.at_css(".client-show-map iframe")
      map_link = document.at_css(".client-map-section a")

      expect(map_frame["src"]).to include("https://www.google.com/maps")
      expect(map_frame["src"]).to include(ERB::Util.url_encode(client.name))
      expect(map_link["href"]).to include("https://www.google.com/maps/search/")
      expect(map_link["href"]).to include(ERB::Util.url_encode(client.name))
      expect(map_link.text).to include("Open in Google Maps")
    end

    it "shows a delivery location map from the address when coordinates are missing" do
      client.update_columns(
        latitude: nil,
        longitude: nil,
        delivery_address_street_1: "54 Mercer St",
        delivery_address_city: "New York",
        delivery_address_state: "NY",
        delivery_address_zipcode: "10013"
      )

      get client_path(client)

      document = Nokogiri::HTML(response.body)
      map_frame = document.at_css(".client-show-map iframe")

      expect(map_frame["src"]).to include("https://www.google.com/maps")
      expect(map_frame["src"]).to include(ERB::Util.url_encode(client.name))
      expect(map_frame["src"]).to include("54%20Mercer%20St%20New%20York%2C%20NY%2010013")
      expect(document.at_css(".client-map-section a")["href"]).to include(ERB::Util.url_encode(client.name))
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
        accounts_payable_contact_phone: "555-1234"
      }
      expect { post clients_path, params: { client: params } }.to change(Client, :count).by(1)
      expect(flash[:notice]).to match(/You have created Wizards Coffee/)
    end

    it "shows edit form" do
      get edit_client_path(client)
      expect(response).to be_successful
    end

    it "shows edit form for a client without shipments" do
      client_without_shipments = create(:client, bakery: bakery)

      get edit_client_path(client_without_shipments)

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

    # policy_scope scopes to current bakery at DB level → RecordNotFound caught → redirect
    it "redirects to index for another bakery's client" do
      other_bakery = create(:bakery)
      other_client = create(:client, bakery: other_bakery)
      create(:shipment, bakery: other_bakery, client: other_client)
      get client_path(other_client)
      expect(response).to redirect_to(clients_path)
      expect(flash[:alert]).to eq("That record no longer exists.")
    end
  end
end
