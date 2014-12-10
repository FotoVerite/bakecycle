module ApplicationHelper
  def class_for_main_content
    return "large-10 medium-10 columns" if user_signed_in?
    "medium-6 medium-offset-3 small-10 small-offset-1 columns"
  end
end
