class Plan < ActiveRecord::Base
  has_many :bakeries
  validates :name, :display_name, presence: true, uniqueness: true

  scope :for_display, -> { order('id asc').first(3) }
end
