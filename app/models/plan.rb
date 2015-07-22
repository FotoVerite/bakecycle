class Plan < ActiveRecord::Base
  has_many :bakeries
  validates :name, :display_name, presence: true, uniqueness: true

  def self.for_display
    plans = %w(beta_small beta_medium beta_large)
    plans.map { |name| find_by(name: name) }.compact
  end
end
