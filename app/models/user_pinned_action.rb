# frozen_string_literal: true

class UserPinnedAction < ApplicationRecord
  MAX_PER_USER = 5

  belongs_to :user

  scope :ordered, -> { order(:position, :id) }

  validates :action_key, presence: true,
                         uniqueness: { scope: :user_id },
                         inclusion: { in: ->(_record) { PinnedActionRegistry.keys } }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :user_pin_limit, on: :create

  private

  def user_pin_limit
    return unless user
    return if self.class.where(user_id: user.id).count < MAX_PER_USER

    errors.add(:base, "You can pin up to #{MAX_PER_USER} actions.")
  end
end
