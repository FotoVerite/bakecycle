class AddDeliveryTimeToShipments < ActiveRecord::Migration
  def change
    change_column :routes, :departure_time, :time, null: false
    add_column :shipments, :route_departure_time, :time
    Shipment.connection.execute('
      UPDATE shipments
        SET route_departure_time = routes.departure_time
        FROM routes
        WHERE shipments.route_id = routes.id
    ')
    change_column :shipments, :route_departure_time, :time, null: false
  end
end
