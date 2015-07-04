class Plan < ActiveRecord::Base
  has_many :bakeries
  validates :name, :display_name, presence: true, uniqueness: true

  def self.for_display
    %w(beta_small beta_medium beta_large).map do |name|
      find_by(name: name)
    end
  end
end
