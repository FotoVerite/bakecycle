module Api
  class ApiController < ApplicationController
    rescue_from Pundit::NotAuthorizedError, with: :not_authorized

    def not_authorized
      render nothing: true, status: :unauthorized
    end
  end
end
