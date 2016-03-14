class OrderSerializer < ActiveModel::Serializer
  attributes :id, :start_date, :end_date, :start_date, :order_type,
    :errors, :client_id, :route_id, :total_lead_days
  has_many :order_items
end
