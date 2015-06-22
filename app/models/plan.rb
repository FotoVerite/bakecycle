class Plan < ActiveRecord::Base
  has_many :bakeries
  validates :name, :display_name, presence: true, uniqueness: true
end
