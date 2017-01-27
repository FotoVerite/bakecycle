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

class FileExport < ActiveRecord::Base
  belongs_to :bakery
  has_attached_file :file,
    use_timestamp: false,
    default_url: "",
    url: "/system/:class/:id/:attachment/:filename"

  validates :bakery, presence: true
  do_not_validate_attachment_file_type :file

  def ready?
    file.present?
  end
end
