# frozen_string_literal: true

class FileExportsController < ApplicationController
  decorates_assigned :file_export

  def show
    render_nav(false)
    @file_export = policy_scope(FileExport).find(params[:id])
    authorize @file_export
    redirect_to @file_export.download_url, allow_other_host: true if @file_export.ready?
  end
end
