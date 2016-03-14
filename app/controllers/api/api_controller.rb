module Api
  class ApiController < ApplicationController
    def not_authorized
      render nothing: true, status: :unauthorized
    end
  end
end
