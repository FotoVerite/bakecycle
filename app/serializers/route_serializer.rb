# == Schema Information
#
# Table name: routes
#
#  id             :integer          not null, primary key
#  name           :string
#  notes          :text
#  active         :boolean          not null
#  departure_time :time             not null
#  bakery_id      :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  legacy_id      :integer
#

class RouteSerializer < ActiveModel::Serializer
  attributes :id, :errors, :name, :notes, :active, :departure_time
end
