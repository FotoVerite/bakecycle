# == Schema Information
#
# Table name: file_actions
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  file_export_id :uuid
#  action         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryGirl.define do
  factory :file_action do
  end
end
