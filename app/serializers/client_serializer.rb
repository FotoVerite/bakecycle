# == Schema Information
#
# Table name: clients
#
#  id                             :integer          not null, primary key
#  name                           :string
#  official_company_name          :string
#  business_phone                 :string
#  business_fax                   :string
#  active                         :boolean          not null
#  delivery_address_street_1      :string
#  delivery_address_street_2      :string
#  delivery_address_city          :string
#  delivery_address_state         :string
#  delivery_address_zipcode       :string
#  billing_address_street_1       :string
#  billing_address_street_2       :string
#  billing_address_city           :string
#  billing_address_state          :string
#  billing_address_zipcode        :string
#  accounts_payable_contact_name  :string
#  accounts_payable_contact_phone :string
#  accounts_payable_contact_email :string
#  primary_contact_name           :string
#  primary_contact_phone          :string
#  primary_contact_email          :string
#  secondary_contact_name         :string
#  secondary_contact_phone        :string
#  secondary_contact_email        :string
#  latitude                       :float
#  longitude                      :float
#  billing_term                   :integer          not null
#  bakery_id                      :integer          not null
#  delivery_minimum               :decimal(, )      default(0.0), not null
#  delivery_fee                   :decimal(, )      default(0.0), not null
#  legacy_id                      :string
#  delivery_fee_option            :integer          not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  ein                            :string
#  notes                          :string
#  sequence_number                :integer          default(5000)
#

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
