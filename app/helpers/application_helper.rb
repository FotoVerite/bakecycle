module ApplicationHelper
  def class_for_main_content
    return "large-10 medium-12 small-12 columns light-grey-bg-pattern" if user_signed_in?
    "medium-6 medium-offset-3 small-10 small-offset-1 columns light-grey-bg-pattern"
  end

  def active?(link_path)
    return "active" if link_path == "/" && controller.controller_name == "static_pages"
    return "active" if link_path.include?(controller.controller_name)
  end
end
