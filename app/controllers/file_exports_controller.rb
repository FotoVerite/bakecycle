class FileExportsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  decorates_assigned :file_export

  def show
    render_side_nav(false)
    redirect_to @file_export.file.to_s if @file_export.ready?
  end
end
