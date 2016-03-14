class RouteSerializer < ActiveModel::Serializer
  attributes :id, :errors, :name, :notes, :active, :departure_time
end
