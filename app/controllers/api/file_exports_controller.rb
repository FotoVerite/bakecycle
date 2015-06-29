module Api
  class FileExportsController < ApiController
    def show
      @file_export = policy_scope(FileExport).find(params[:id])
      authorize @file_export
      render json: @file_export
    end
  end
end
