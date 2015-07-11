class OrderSearchForm < BaseSearchForm
  search_for_many :client_id, :product_id, :route_id
  search_for_date :date
end
