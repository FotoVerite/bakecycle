module Api
  class FileExportsController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource

    def show
      render json: @file_export
    end
  end
end
