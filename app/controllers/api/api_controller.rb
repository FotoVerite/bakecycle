module Api
  class ApiController < ApplicationController
    def not_authorized
      head :unauthorized
    end
  end
end
