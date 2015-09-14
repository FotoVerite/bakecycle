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
