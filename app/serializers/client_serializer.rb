class ClientSerializer < ActiveModel::Serializer
  attributes :id, :name, :official_company_name, :active, :errors, :links, :latitude, :longitude,
    :delivery_address_full

  def links
    {
      view: Rails.application.routes.url_helpers.client_path(object),
      edit: Rails.application.routes.url_helpers.edit_client_path(object),
      newOrder: Rails.application.routes.url_helpers.new_order_path(client_id: object.id)
     }
  end
end
