# frozen_string_literal: true

module Api
  class FileExportsController < ApiController
    def show
      @file_export = policy_scope(FileExport).find(params[:id])
      authorize @file_export
      render json: { fileExport: file_export_json(@file_export) }
    end

    private

    def file_export_json(export)
      {
        id: export.id,
        createdAt: export.created_at,
        updatedAt: export.updated_at,
        "ready?" => export.ready?,
        loadingMessage: LoadingMessages.sample,
        links: {
          self: api_file_export_path(export),
          file: export.download_url
        }
      }
    end
  end
end
