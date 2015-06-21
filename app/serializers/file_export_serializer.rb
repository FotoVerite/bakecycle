class FileExportSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :links, :ready?

  def links
    {
      self: Rails.application.routes.url_helpers.api_file_export_path(object),
      pdf: pdf
    }
  end

  def pdf
    object.file.url if object.ready?
  end
end
