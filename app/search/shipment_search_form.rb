class ShipmentSearchForm < BaseSearchForm
  search_for_many :client_id, :product_id
  search_for_date :date_from, :date_to
end
