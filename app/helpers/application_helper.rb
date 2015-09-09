module ApplicationHelper
  def render_nav?
    @_render_nav
  end

  def class_for_main_content
    return "large-10 medium-12 small-12 columns light-grey-bg-pattern" if render_nav?
    "medium-6 medium-offset-3 small-10 small-offset-1 columns light-grey-bg-pattern"
  end

  def active_nav?(*sections)
    "active show-nav" if sections.include? @_active_nav
  end

  def full_title(page_title = nil)
    base_title = "Bakecycle"
    return base_title if page_title.empty?
    "#{page_title} - #{base_title}".html_safe
  end

  def resque_info_table
    render partial: "resque_info_table", locals: { info: Resque.info }
  end

  def funny_loading_message
    LoadingMessages.sample
  end

  def loading_indicator
    render "loading_indicator"
  end
end
