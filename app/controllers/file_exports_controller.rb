class FileExportsController < ApplicationController
  decorates_assigned :file_export

  def show
    render_side_nav(false)
    @file_export = policy_scope(FileExport).find(params[:id])
    authorize @file_export
    redirect_to @file_export.file.to_s if @file_export.ready?
  end
end
