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

require "rails_helper"

RSpec.describe FileAction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
