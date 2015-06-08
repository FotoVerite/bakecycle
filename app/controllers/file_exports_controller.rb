class FileExportsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def show
    redirect_to @file_export.file.to_s if @file_export.ready?
  end
end
