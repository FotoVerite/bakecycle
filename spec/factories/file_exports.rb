# frozen_string_literal: true

# == Schema Information
#
# Table name: file_exports
#
#  id                :uuid             not null, primary key
#  bakery_id         :integer          not null
#  user_id           :integer
#  file_file_name    :string
#  file_content_type :string
#  file_file_size    :integer
#  file_updated_at   :datetime
#  file_fingerprint  :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryBot.define do
  factory :file_export do
    bakery { create(:bakery) }
    user { association(:user, bakery: bakery) }
    trait :with_file do
      file { File.new(Rails.root.join("app/assets/images/example_logo.png")) }
    end
  end
end
