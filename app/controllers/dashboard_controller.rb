class DashboardController < ApplicationController
  before_action :skip_authorization, :skip_policy_scope

  def index
    active_nav(:dashboard)
  end
end
