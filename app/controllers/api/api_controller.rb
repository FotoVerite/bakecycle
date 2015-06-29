module Api
  class ApiController < ApplicationController
    before_action :authenticate_user!
    rescue_from Pundit::NotAuthorizedError, with: :not_authorized

    def not_authorized
      render nothing: true, status: :unauthorized
    end
  end
end
