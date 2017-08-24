# == Schema Information
#
# Table name: orders
#
#  id                      :integer          not null, primary key
#  client_id               :integer          not null
#  route_id                :integer
#  start_date              :date             not null
#  end_date                :date
#  note                    :text             default(""), not null
#  order_type              :string           not null
#  bakery_id               :integer          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  legacy_id               :integer
#  total_lead_days         :integer          not null
#  version_number          :integer          default(0)
#  created_by_user_id      :integer
#  last_updated_by_user_id :integer
#  alert                   :boolean          default(FALSE)
#

class OrderSerializer < ActiveModel::Serializer
  attributes :alert, :id, :start_date, :end_date, :start_date, :order_type,
    :errors, :client_id, :route_id, :total_lead_days, :note
  has_many :order_items
end
