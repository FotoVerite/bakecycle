class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception
  before_action :active_nav
  before_action :resque_no_worker if Rails.env.development?
  helper_method :current_bakery
  helper_method :item_finder

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from CanCan::AccessDenied, with: :user_not_authorized

  def active_nav(name = nil)
    @_active_nav = name || controller_name.to_sym
  end

  def current_bakery
    current_user.bakery if current_user
  end

  def item_finder
    @_item_finder ||= ItemFinder.new(current_ability)
  end

  def after_sign_in_path_for(_resource)
    dashboard_path
  end

  def after_sign_out_path_for(_resource)
    root_path
  end

  def resque_no_worker
    return if Resque.info[:workers] > 0 || Resque.inline
    flash.alert = 'There are no resque workers and Resque.inline is false'
  end

  private

  def redirect_path
    return dashboard_path if user_signed_in?
    root_path
  end

  def user_not_authorized
    flash[:alert] = 'You are not authorized to access this page.'
    redirect_to(request.referrer || redirect_path)
  end
end
