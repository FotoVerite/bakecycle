class User < ActiveRecord::Base
  belongs_to :bakery
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  validates :name, length: { maximum: 150 }
end
