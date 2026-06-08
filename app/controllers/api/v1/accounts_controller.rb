# frozen_string_literal: true

module Api
  module V1
    class AccountsController < ActionController::Base
      use JwtAuth

      ATTRIBUTES = %i[
        name
        business_phone
        business_fax
        delivery_address_street_1
        delivery_address_street_2
        delivery_address_city
        delivery_address_state
        delivery_address_zipcode
        billing_address_street_1
        billing_address_street_2
        billing_address_city
        billing_address_state
        billing_address_zipcode
        accounts_payable_contact_name
        accounts_payable_contact_phone
        accounts_payable_contact_email
        primary_contact_name
        primary_contact_phone
        primary_contact_email
        secondary_contact_name
        secondary_contact_phone
        secondary_contact_email
        notes
        wholesale_manager
      ].freeze

      def show
        client_id = request.env.values_at :client_id
        render json: { success: true, client: Client.select(ATTRIBUTES).find(client_id[0]) }
      end

      def update
        client_id = request.env.values_at :client_id
        client = Client.find(client_id[0])
        if client.update(client_params)
          render json: { success: true, client: Client.select(ATTRIBUTES).find(client_id[0]) }
        else
          render json: { success: false, client: Client.select(ATTRIBUTES).find(client_id[0]) }
        end
      end

      private

      def client_params
        params.require(:client).permit(
          ATTRIBUTES
        )
      end
    end
  end
end
