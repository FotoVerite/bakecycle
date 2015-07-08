class User < ActiveRecord::Base
  ACCESS_LEVELS = %w(none read manage)
  belongs_to :bakery
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable, :invitable

  validates :name, length: { maximum: 150 }
  validates :user_permission,
            :product_permission,
            :bakery_permission,
            :client_permission,
            presence: true,
            inclusion: { in: ACCESS_LEVELS }

  def self.sort_by_bakery_and_name
    includes(:bakery)
      .joins('LEFT OUTER JOIN bakeries ON bakeries.id = users.bakery_id')
      .order('lower(bakeries.name) ASC', 'lower(users.name) ASC')
  end
end
