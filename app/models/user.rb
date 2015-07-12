class User < ActiveRecord::Base
  ACCESS_LEVELS = %w(none read manage)
  belongs_to :bakery
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :async, :database_authenticatable, :invitable, :recoverable, :rememberable,
    :trackable, :validatable

  validates :name, length: { maximum: 150 }
  validates :name, presence: true
  validates :email, uniqueness: true, unless: 'email.blank?'
  validates :email, presence: true
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
      .joins('LEFT OUTER JOIN bakeries ON bakeries.id = users.bakery_id')
      .order('lower(bakeries.name) ASC', 'lower(users.name) ASC')
  end
end
