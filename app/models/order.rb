class Order < ActiveRecord::Base
  belongs_to :client
  belongs_to :route

  validates :route, :client, :start_date, presence: true
end
