class ApplicationController < ActionController::Base
  include Pundit
  after_action :verify_authorized, :verify_policy_scoped, unless: :devise_controller?
  before_action :active_nav
  before_action :authenticate_user!
  before_action :default_side_nav
  before_action :resque_no_worker if Rails.env.development?
  helper_method :current_bakery
  helper_method :item_finder
  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError, with: :not_authorized

  def active_nav(name = nil)
    @_active_nav = name || controller_name.to_sym
  end

  def default_side_nav
    @_render_side_nav = user_signed_in?
  end

  def render_side_nav(render = true)
    @_render_side_nav = render
  end

  def current_bakery
    current_user.bakery if current_user
  end

  def item_finder
    @_item_finder ||= ItemFinder.new(current_user)
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

  def not_authorized
    flash[:alert] = 'You are not authorized to access this page.'
    redirect_to(request.referrer || redirect_path)
  end
end
