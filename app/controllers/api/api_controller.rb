# frozen_string_literal: true

module Api
  class ApiController < ApplicationController
    def not_authorized
      head :unauthorized
    end

    def record_not_found
      head :not_found
    end
  end
end
