# frozen_string_literal: true

class AddRouteNameToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :route_name, :string
  end
end
