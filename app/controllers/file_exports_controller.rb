# frozen_string_literal: true

class FileExportsController < ApplicationController
  decorates_assigned :file_export

  def index
    authorize FileExport
    # Not paginated -- capped at the 10 most recent. Exports themselves are never
    # deleted (invoices live here and must be retained), this just bounds what the
    # quick-access history view shows by default.
    @file_exports = policy_scope(FileExport).order(created_at: :desc).limit(10)
  end

  def show
    render_nav(false)
    @file_export = policy_scope(FileExport).find(params[:id])
    authorize @file_export
    redirect_to @file_export.download_url, allow_other_host: true if @file_export.ready?
  end
end
