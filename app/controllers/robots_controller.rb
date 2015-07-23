class RobotsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :skip_authorization, :skip_policy_scope
  def robots
    if Rails.env.production?
      render 'allow.txt', layout: false, content_type: 'text/plain'
    else
      render 'disallow.txt', layout: false, content_type: 'text/plain'
    end
  end
end
