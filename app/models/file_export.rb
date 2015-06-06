class FileExport < ActiveRecord::Base
  belongs_to :bakery

  has_attached_file :file,
    default_url: '',
    url: '/system/:class/:id/:attachment/:filename'

  do_not_validate_attachment_file_type :file

  def ready?
    file.present?
  end
end
