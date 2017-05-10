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

class FileAction < ActiveRecord::Base
  belongs_to :file_export
  belongs_to :user
  belongs_to :bakery
end
