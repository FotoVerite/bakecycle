class User < ActiveRecord::Base
  ACCESS_LEVELS = %w(none read manage)
  belongs_to :bakery
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  validates :name, length: { maximum: 150 }
  validates :user_permission, presence: true, inclusion: { in: ACCESS_LEVELS }

  def self.sort_by_bakery
    joins('LEFT OUTER JOIN bakeries ON bakeries.id = users.bakery_id')
      .order('lower(bakeries.name) ASC')
  end
end
