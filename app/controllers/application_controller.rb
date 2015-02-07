class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :active_nav
  helper_method :current_bakery
  helper_method :item_finder

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to root_url, alert: "Resource not found"
  end

  def active_nav(name = nil)
    @_active_nav = name || controller_name.to_sym
  end

  def current_bakery
    current_user.bakery if current_user
  end

  def item_finder
    @_item_finder ||= ItemFinder.new(current_ability)
  end
end
