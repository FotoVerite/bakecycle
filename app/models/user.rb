# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  name                   :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  bakery_id              :integer
#  admin                  :boolean          default(FALSE)
#  user_permission        :string           default("none"), not null
#  product_permission     :string           default("none"), not null
#  bakery_permission      :string           default("none"), not null
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string
#  client_permission      :string           default("none"), not null
#  shipping_permission    :string           default("none"), not null
#  production_permission  :string           default("none"), not null
#

class User < ApplicationRecord
  ACCESS_LEVELS = %w[none read manage].freeze
  belongs_to :bakery
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :async, :database_authenticatable, :invitable, :recoverable, :rememberable,
    :trackable, :validatable

  validates :name, length: { maximum: 150 }
  validates :name, presence: true
  validates :user_permission,
            :production_permission,
            :product_permission,
            :bakery_permission,
            :client_permission,
            :shipping_permission,
            presence: true,
            inclusion: { in: ACCESS_LEVELS }

  def self.sort_by_bakery_and_name
    includes(:bakery)
      .joins("LEFT OUTER JOIN bakeries ON bakeries.id = users.bakery_id")
      .order("lower(bakeries.name) ASC", "lower(users.name) ASC")
  end
end
