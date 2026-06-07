class ApplicationController < ActionController::Base
  include Pundit::Authorization
  after_action :verify_authorized, :verify_policy_scoped, unless: :devise_controller?
  before_action :active_nav
  before_action :authenticate_user!
  before_action :default_nav
  before_action :no_job_workers if Rails.env.development?
  before_action :set_paper_trail_whodunnit

  helper_method :current_bakery
  helper_method :item_finder
  protect_from_forgery with: :exception,  prepend: true

  rescue_from Pundit::NotAuthorizedError, with: :not_authorized

  def active_nav(name = nil)
    @_active_nav = name || controller_name.to_sym
  end

  def default_nav
    @_render_nav = user_signed_in?
  end

  def render_nav(render = true)
    @_render_nav = render
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
    root_path(message: true)
  end

  def no_job_workers
    return if SolidQueue::Process.any?

    flash.now.alert = "No Solid Queue workers running. Start with: bin/jobs"
  end

  private

  def redirect_path
    return dashboard_path if user_signed_in?

    root_path(message: true)
  end

  def not_authorized
    flash[:alert] = "You are not authorized to access this page."
    redirect_to(request.referer || redirect_path)
  end

  def parsed_date_param(*keys, fallback: Time.zone.today)
    parsed_date_value(date_param_value(*keys), fallback: fallback)
  end

  def optional_parsed_date_param(*keys)
    parsed_date_value(date_param_value(*keys), fallback: nil)
  end

  def date_param_value(*keys)
    keys.each do |key|
      value = params[key]
      return value if value.present?

      %i[search print].each do |param_group|
        value = params.dig(param_group, key)
        return value if value.present?
      end
    end

    nil
  end

  def parsed_date_value(value, fallback:)
    date = Chronic.parse(value.to_s) if value.present?
    date ||= fallback
    date.to_date if date
  end
end
