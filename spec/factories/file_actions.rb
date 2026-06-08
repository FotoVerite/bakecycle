# frozen_string_literal: true

# == Schema Information
#
# Table name: file_actions
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  bakery_id      :integer
#  file_export_id :uuid
#  action         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryBot.define do
  factory :file_action do
    bakery { create(:bakery) }
    user { create(:user, bakery: bakery) }
    file_export { create(:file_export, bakery: bakery) }
  end
end
