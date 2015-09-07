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
