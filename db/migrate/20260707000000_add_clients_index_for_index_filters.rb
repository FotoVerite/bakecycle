# frozen_string_literal: true

class AddClientsIndexForIndexFilters < ActiveRecord::Migration[8.1]
  def change
    add_index :clients,
              %i[bakery_id active engagement_status name],
              name: "index_clients_on_bakery_active_status_name"
  end
end
