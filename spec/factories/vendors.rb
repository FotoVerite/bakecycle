# == Schema Information
#
# Table name: vendors
#
#  id         :integer          not null, primary key
#  bakery_id  :integer
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :vendor do
    bakery { create(:bakery) }
  end
end
