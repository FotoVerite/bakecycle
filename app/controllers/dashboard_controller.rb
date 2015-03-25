class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    active_nav(:dashboard)
  end
end
