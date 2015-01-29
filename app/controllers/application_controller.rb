class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :active_nav

  def active_nav(name = nil)
    @_active_nav = name || controller_name.to_sym
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end
end
