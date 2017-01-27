# == Schema Information
#
# Table name: file_exports
#
#  id                :uuid             not null, primary key
#  bakery_id         :integer          not null
#  file_file_name    :string
#  file_content_type :string
#  file_file_size    :integer
#  file_updated_at   :datetime
#  file_fingerprint  :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryGirl.define do
  factory :file_export do
    bakery
    trait :with_file do
      file { File.new(Rails.root.join("app/assets/images/example_logo.png")) }
    end
  end
end
