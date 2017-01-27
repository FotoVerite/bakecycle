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

class FileExportSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :links, :ready?, :loading_message

  def links
    {
      self: Rails.application.routes.url_helpers.api_file_export_path(object),
      file: file
    }
  end

  private

  def file
    object.file.url if object.ready?
  end

  def loading_message
    LoadingMessages.sample
  end
end
